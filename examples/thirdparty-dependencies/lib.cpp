// =============================================================================
// SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
// SPDX-License-Identifier: Apache-2.0
// =============================================================================

#include <fmt/format.h>
#include <spdlog/spdlog.h>
#include <string>

namespace third - party_example
{

  std::string format_message()
  {
    // Use fmt library (from cmake/thirdparty/get_fmt.cmake)
    return fmt::format("third-party-dependencies example using fmt {}.{}.{}",
                       FMT_VERSION / 10000,
                       (FMT_VERSION % 10000) / 100,
                       FMT_VERSION % 100);
  }

  void log_message(const std::string& message)
  {
    // Use spdlog library (from cmake/thirdparty/get_spdlog.cmake)
    spdlog::info(
      "spdlog v{}.{}.{}: {}", SPDLOG_VER_MAJOR, SPDLOG_VER_MINOR, SPDLOG_VER_PATCH, message);
  }

}  // namespace third- party_example
