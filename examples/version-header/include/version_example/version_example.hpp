// =============================================================================
// SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
// SPDX-License-Identifier: Apache-2.0
// =============================================================================

#pragma once

#include <string>

namespace version_example {

/**
 * @brief Get the library version as a string
 *
 * @return Version string in format "MAJOR.MINOR.PATCH"
 */
std::string version();

/**
 * @brief Get the major version number
 */
int version_major();

/**
 * @brief Get the minor version number
 */
int version_minor();

/**
 * @brief Get the patch version number
 */
int version_patch();

}  // namespace version_example
