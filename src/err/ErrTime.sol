// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// Thrown when a timestamp is later than the time it is measured against.
/// @param timestamp The timestamp.
/// @param now_ The time it was measured against.
error FutureTimestamp(uint256 timestamp, uint256 now_);
