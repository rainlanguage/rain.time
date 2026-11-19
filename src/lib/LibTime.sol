// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {FutureTimestamp} from "../err/ErrTime.sol";

/// @title LibTime
/// @notice Ages of timestamps. A staleness check is `age(timestamp) > maxAge`,
/// which cannot overflow for any `maxAge`, unlike `timestamp + maxAge`.
library LibTime {
    /// Seconds from `timestamp` to `currentTimestamp`.
    /// @param timestamp The timestamp to age.
    /// @param currentTimestamp The time to measure against.
    /// @return The age, `currentTimestamp - timestamp`. Reverts `FutureTimestamp` if
    /// `timestamp > currentTimestamp`.
    function ageAt(uint256 timestamp, uint256 currentTimestamp) internal pure returns (uint256) {
        //slither-disable-next-line timestamp
        if (timestamp > currentTimestamp) {
            revert FutureTimestamp(timestamp, currentTimestamp);
        }
        // timestamp <= currentTimestamp.
        unchecked {
            return currentTimestamp - timestamp;
        }
    }

    /// Seconds from `timestamp` to `block.timestamp`.
    /// @param timestamp The timestamp to age.
    /// @return The age, as `ageAt(timestamp, block.timestamp)`.
    function age(uint256 timestamp) internal view returns (uint256) {
        return ageAt(timestamp, block.timestamp);
    }
}
