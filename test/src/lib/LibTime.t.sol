// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {LibTime} from "src/lib/LibTime.sol";
import {FutureTimestamp} from "src/err/ErrTime.sol";

contract LibTimeTest is Test {
    function externalAgeAt(uint256 timestamp, uint256 currentTimestamp) external pure returns (uint256) {
        return LibTime.ageAt(timestamp, currentTimestamp);
    }

    function externalAge(uint256 timestamp) external view returns (uint256) {
        return LibTime.age(timestamp);
    }

    function testAgeAtPast(uint256 currentTimestamp, uint256 elapsed) external pure {
        elapsed = bound(elapsed, 0, currentTimestamp);
        assertEq(LibTime.ageAt(currentTimestamp - elapsed, currentTimestamp), elapsed);
    }

    function testAgeAtSameTime(uint256 currentTimestamp) external pure {
        assertEq(LibTime.ageAt(currentTimestamp, currentTimestamp), 0);
    }

    function testAgeAtFutureReverts(uint256 timestamp, uint256 currentTimestamp) external {
        vm.assume(timestamp > currentTimestamp);
        vm.expectRevert(abi.encodeWithSelector(FutureTimestamp.selector, timestamp, currentTimestamp));
        this.externalAgeAt(timestamp, currentTimestamp);
    }

    function testAgeAtFixedExamples() external pure {
        assertEq(LibTime.ageAt(0, 0), 0);
        assertEq(LibTime.ageAt(0, type(uint256).max), type(uint256).max);
        assertEq(LibTime.ageAt(type(uint256).max, type(uint256).max), 0);
        assertEq(LibTime.ageAt(1700000000, 1700003600), 3600);
    }

    function testAgeIsAgeAtBlockTimestamp(uint256 currentTimestamp, uint256 timestamp) external {
        vm.warp(currentTimestamp);
        if (timestamp > currentTimestamp) {
            vm.expectRevert(abi.encodeWithSelector(FutureTimestamp.selector, timestamp, currentTimestamp));
            this.externalAge(timestamp);
        } else {
            assertEq(this.externalAge(timestamp), currentTimestamp - timestamp);
        }
    }

    /// A max age so large that `timestamp + maxAge` overflows never makes the
    /// timestamp stale.
    function testMaxAgeOverflowNotStale(uint256 currentTimestamp, uint256 timestamp, uint256 maxAge) external pure {
        vm.assume(currentTimestamp > 0);
        timestamp = bound(timestamp, 1, currentTimestamp);
        maxAge = bound(maxAge, type(uint256).max - timestamp + 1, type(uint256).max);
        assertFalse(LibTime.ageAt(timestamp, currentTimestamp) > maxAge);
    }
}
