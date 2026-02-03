// =============================================================================
// SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
// SPDX-License-Identifier: Apache-2.0
// =============================================================================

#include <iostream>
#include <string>

namespace third - party_example
{
  std::string format_message();
  void log_message(const std::string& message);
}  // namespace third- party_example

int main()
{
  std::cout << "third-party-dependencies example\n";
  std::cout << "================================\n\n";

  std::cout << "This example demonstrates the cmake/thirdparty/ organization pattern\n";
  std::cout << "used by ALL RAPIDS projects (RMM, cuDF, cuVS) for managing dependencies.\n\n";

  std::cout << "Directory structure:\n";
  std::cout << "  cmake/thirdparty/\n";
  std::cout << "  ├── get_fmt.cmake     - Simple dependency\n";
  std::cout << "  └── get_spdlog.cmake  - Dependency with custom patch\n\n";

  // Use dependencies from cmake/thirdparty/
  auto message = third - party_example::format_message();
  std::cout << "Formatted message: " << message << "\n\n";

  std::cout << "Logging via spdlog:\n";
  third - party_example::log_message("Third-party dependencies configured successfully!");

  std::cout << "\nBenefits of this pattern:\n";
  std::cout << "  ✓ Scalable: cuDF manages 15+ dependencies this way\n";
  std::cout << "  ✓ Maintainable: One file per dependency\n";
  std::cout << "  ✓ Reusable: Share get_*.cmake files across projects\n";
  std::cout << "  ✓ Flexible: Conditional dependencies, custom patches\n";

  return 0;
}
