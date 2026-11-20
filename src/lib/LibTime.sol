// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {FutureTimestamp} from "../err/ErrTime.sol";

/// @title LibTime
/// @notice Ages and staleness of timestamps. Staleness is computed from the
/// age, so it cannot overflow for any `maxAge`, unlike `timestamp + maxAge`.
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

    /// Whether `timestamp` is stale at `referenceTimestamp`. Fails closed: the
    /// edge instant (age == maxAge) is stale, and an unset (zero) timestamp is
    /// always stale.
    /// @param timestamp The timestamp to check.
    /// @param maxAge Ages at or above this are stale.
    /// @param referenceTimestamp The time to measure against.
    /// @return True if stale. Reverts `FutureTimestamp` if
    /// `timestamp > referenceTimestamp`.
    function isStaleAt(uint256 timestamp, uint256 maxAge, uint256 referenceTimestamp) internal pure returns (bool) {
        return timestamp == 0 || ageAt(timestamp, referenceTimestamp) >= maxAge;
    }

    /// Whether `timestamp` is stale at `block.timestamp`.
    /// @param timestamp The timestamp to check.
    /// @param maxAge Ages at or above this are stale.
    /// @return As `isStaleAt(timestamp, maxAge, block.timestamp)`.
    function isStale(uint256 timestamp, uint256 maxAge) internal view returns (bool) {
        return isStaleAt(timestamp, maxAge, block.timestamp);
    }
}
