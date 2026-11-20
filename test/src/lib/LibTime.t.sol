// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {LibTime} from "src/lib/LibTime.sol";
import {FutureTimestamp} from "src/err/ErrTime.sol";

contract LibTimeTest is Test {
    function externalAgeAt(uint256 timestamp, uint256 referenceTimestamp) external pure returns (uint256) {
        return LibTime.ageAt(timestamp, referenceTimestamp);
    }

    function externalAge(uint256 timestamp) external view returns (uint256) {
        return LibTime.age(timestamp);
    }

    function testAgeAtPast(uint256 referenceTimestamp, uint256 elapsed) external pure {
        elapsed = bound(elapsed, 0, referenceTimestamp);
        assertEq(LibTime.ageAt(referenceTimestamp - elapsed, referenceTimestamp), elapsed);
    }

    function testAgeAtSameTime(uint256 referenceTimestamp) external pure {
        assertEq(LibTime.ageAt(referenceTimestamp, referenceTimestamp), 0);
    }

    function testAgeAtFutureReverts(uint256 timestamp, uint256 referenceTimestamp) external {
        vm.assume(timestamp > referenceTimestamp);
        vm.expectRevert(abi.encodeWithSelector(FutureTimestamp.selector, timestamp, referenceTimestamp));
        this.externalAgeAt(timestamp, referenceTimestamp);
    }

    function testAgeAtFixedExamples() external pure {
        assertEq(LibTime.ageAt(0, 0), 0);
        assertEq(LibTime.ageAt(0, type(uint256).max), type(uint256).max);
        assertEq(LibTime.ageAt(type(uint256).max, type(uint256).max), 0);
        assertEq(LibTime.ageAt(1700000000, 1700003600), 3600);
    }

    function testAgeIsAgeAtBlockTimestamp(uint256 referenceTimestamp, uint256 timestamp) external {
        vm.warp(referenceTimestamp);
        if (timestamp > referenceTimestamp) {
            vm.expectRevert(abi.encodeWithSelector(FutureTimestamp.selector, timestamp, referenceTimestamp));
            this.externalAge(timestamp);
        } else {
            assertEq(this.externalAge(timestamp), referenceTimestamp - timestamp);
        }
    }

    /// A max age so large that `timestamp + maxAge` overflows never makes the
    /// timestamp stale.
    function testMaxAgeOverflowNotStale(uint256 referenceTimestamp, uint256 timestamp, uint256 maxAge) external pure {
        vm.assume(referenceTimestamp > 0);
        timestamp = bound(timestamp, 1, referenceTimestamp);
        maxAge = bound(maxAge, type(uint256).max - timestamp + 1, type(uint256).max);
        assertFalse(LibTime.ageAt(timestamp, referenceTimestamp) > maxAge);
    }

    function externalIsStaleAt(uint256 timestamp, uint256 maxAge, uint256 referenceTimestamp)
        external
        pure
        returns (bool)
    {
        return LibTime.isStaleAt(timestamp, maxAge, referenceTimestamp);
    }

    function externalIsStale(uint256 timestamp, uint256 maxAge) external view returns (bool) {
        return LibTime.isStale(timestamp, maxAge);
    }

    function testIsStaleAtPast(uint256 timestamp, uint256 maxAge, uint256 referenceTimestamp) external pure {
        vm.assume(referenceTimestamp > 0);
        timestamp = bound(timestamp, 1, referenceTimestamp);
        assertEq(LibTime.isStaleAt(timestamp, maxAge, referenceTimestamp), referenceTimestamp - timestamp >= maxAge);
    }

    function testIsStaleAtZeroTimestamp(uint256 maxAge, uint256 referenceTimestamp) external pure {
        assertTrue(LibTime.isStaleAt(0, maxAge, referenceTimestamp));
    }

    function testIsStaleAtFutureReverts(uint256 timestamp, uint256 maxAge, uint256 referenceTimestamp) external {
        vm.assume(timestamp > referenceTimestamp);
        vm.expectRevert(abi.encodeWithSelector(FutureTimestamp.selector, timestamp, referenceTimestamp));
        this.externalIsStaleAt(timestamp, maxAge, referenceTimestamp);
    }

    function testIsStaleAtFixedExamples() external pure {
        // Edge instant: age == maxAge is stale.
        assertTrue(LibTime.isStaleAt(1700000000, 3600, 1700003600));
        assertFalse(LibTime.isStaleAt(1700000000, 3600, 1700003599));
        assertTrue(LibTime.isStaleAt(1700000000, 3600, 1700003601));
        // maxAge 0: even age 0 is stale.
        assertTrue(LibTime.isStaleAt(1700000000, 0, 1700000000));
        // maxAge 1: only age 0 is fresh.
        assertFalse(LibTime.isStaleAt(1700000000, 1, 1700000000));
        // Zero timestamp is stale even when its age is below maxAge.
        assertTrue(LibTime.isStaleAt(0, type(uint256).max, 0));
        assertTrue(LibTime.isStaleAt(0, type(uint256).max, 1));
    }

    /// `timestamp + maxAge` overflows; a non-zero past timestamp is fresh.
    function testIsStaleAtMaxAgeOverflow(uint256 timestamp, uint256 referenceTimestamp) external pure {
        vm.assume(referenceTimestamp > 0);
        timestamp = bound(timestamp, 1, referenceTimestamp);
        assertFalse(LibTime.isStaleAt(timestamp, type(uint256).max, referenceTimestamp));
    }

    function testIsStaleIsIsStaleAtBlockTimestamp(uint256 timestamp, uint256 maxAge, uint256 referenceTimestamp)
        external
    {
        vm.warp(referenceTimestamp);
        if (timestamp > referenceTimestamp) {
            vm.expectRevert(abi.encodeWithSelector(FutureTimestamp.selector, timestamp, referenceTimestamp));
            this.externalIsStale(timestamp, maxAge);
        } else {
            assertEq(
                this.externalIsStale(timestamp, maxAge), timestamp == 0 || referenceTimestamp - timestamp >= maxAge
            );
        }
    }

    function testAgeFixedExamples() external {
        vm.warp(1700003600);
        assertEq(LibTime.age(1700000000), 3600);
        assertEq(LibTime.age(1700003600), 0);
    }

    function testIsStaleFixedExamples() external {
        vm.warp(1700003600);
        assertTrue(LibTime.isStale(1700000000, 3600));
        assertFalse(LibTime.isStale(1700000000, 3601));
        assertFalse(LibTime.isStale(1700000001, 3600));
        assertTrue(LibTime.isStale(0, type(uint256).max));
    }
}
