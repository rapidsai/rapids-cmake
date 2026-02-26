// =============================================================================
// SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
// SPDX-License-Identifier: Apache-2.0
// =============================================================================

#include <iostream>
#include <string>

namespace thirdparty_example {
std::string format_message();
void log_message(const std::string& message);
}  // namespace thirdparty_example

int main()
{
  std::cout << "third-party-dependencies example\n";
  std::cout << "================================\n\n";

  std::cout << "This example demonstrates the cmake/thirdparty/ organization pattern\n";
  std::cout << "Directory structure:\n";
  std::cout << "  cmake/thirdparty/\n";
  std::cout << "  ├── get_fmt.cmake     - Simple dependency\n";
  std::cout << "  └── get_spdlog.cmake  - Dependency with custom patch\n\n";

  // Use dependencies from cmake/thirdparty/
  auto message = thirdparty_example::format_message();
  std::cout << "Formatted message: " << message << "\n\n";

  std::cout << "Logging via spdlog:\n";
  thirdparty_example::log_message("Third-party dependencies configured successfully!");

  return 0;
}
