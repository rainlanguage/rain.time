// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {FutureTimestamp} from "../err/ErrTime.sol";

/// @title LibTime
/// @notice Ages of timestamps. A staleness check is `age(timestamp) > maxAge`,
/// which cannot overflow for any `maxAge`, unlike `timestamp + maxAge`.
library LibTime {
    /// Seconds from `timestamp` to `referenceTimestamp`.
    /// @param timestamp The timestamp to age.
    /// @param referenceTimestamp The time to measure against.
    /// @return The age, `referenceTimestamp - timestamp`. Reverts `FutureTimestamp` if
    /// `timestamp > referenceTimestamp`.
    function ageAt(uint256 timestamp, uint256 referenceTimestamp) internal pure returns (uint256) {
        //slither-disable-next-line timestamp
        if (timestamp > referenceTimestamp) {
            revert FutureTimestamp(timestamp, referenceTimestamp);
        }
        // timestamp <= referenceTimestamp.
        unchecked {
            return referenceTimestamp - timestamp;
        }
    }

    /// Seconds from `timestamp` to `block.timestamp`.
    /// @param timestamp The timestamp to age.
    /// @return The age, as `ageAt(timestamp, block.timestamp)`.
    function age(uint256 timestamp) internal view returns (uint256) {
        return ageAt(timestamp, block.timestamp);
    }
}
