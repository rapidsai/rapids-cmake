// =============================================================================
// SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
// SPDX-License-Identifier: Apache-2.0
// =============================================================================

#include <version_example/version_config.hpp>
#include <version_example/version_example.hpp>

namespace version_example {

std::string version()
{
  // Use the generated macro from version_config.hpp
  // Note: Macro naming uses lowercase project name with underscores
  return std::to_string(version_header_example_VERSION_MAJOR) + "." +
         std::to_string(version_header_example_VERSION_MINOR) + "." +
         std::to_string(version_header_example_VERSION_PATCH);
}

int version_major() { return version_header_example_VERSION_MAJOR; }

int version_minor() { return version_header_example_VERSION_MINOR; }

int version_patch() { return version_header_example_VERSION_PATCH; }

}  // namespace version_example
