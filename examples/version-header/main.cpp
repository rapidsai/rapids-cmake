// =============================================================================
// SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
// SPDX-License-Identifier: Apache-2.0
// =============================================================================

#include <iostream>
#include <version_example/version_config.hpp>
#include <version_example/version_example.hpp>

int main()
{
  std::cout << "version-header example\n";
  std::cout << "======================\n\n";

  std::cout << "This example demonstrates rapids_cmake_write_version_file()\n";
  std::cout << "which generates C++ headers containing version information.\n\n";

  std::cout << "Version information from generated header:\n";
  std::cout << "  Full version: " << version_example::version() << "\n";
  std::cout << "  Major: " << version_example::version_major() << "\n";
  std::cout << "  Minor: " << version_example::version_minor() << "\n";
  std::cout << "  Patch: " << version_example::version_patch() << "\n\n";

  std::cout << "Version macros from version_config.hpp:\n";
  std::cout << "  Note: Macros use lowercase project name with underscores\n";
  std::cout << "  version_header_example_VERSION_MAJOR = " << version_header_example_VERSION_MAJOR
            << "\n";
  std::cout << "  version_header_example_VERSION_MINOR = " << version_header_example_VERSION_MINOR
            << "\n";
  std::cout << "  version_header_example_VERSION_PATCH = " << version_header_example_VERSION_PATCH
            << "\n\n";

  std::cout << "This pattern is used by ALL RAPIDS projects:\n";
  std::cout << "  - RMM: include/rmm/version_config.hpp\n";
  std::cout << "  - cuDF: include/cudf/version_config.hpp\n";
  std::cout << "  - cuVS: include/cuvs/version_config.h\n";

  return 0;
}
