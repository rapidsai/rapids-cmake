# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

# Example function
function(find_and_configure_spdlog)
  include(${rapids-cmake-dir}/cpm/package_override.cmake)
  include(${rapids-cmake-dir}/cpm/detail/package_info.cmake)

  rapids_cpm_package_override(${CMAKE_CURRENT_LIST_DIR}/spdlog_version.json)

  rapids_cpm_package_info(spdlog VERSION_VAR spdlog_version CPM_VAR spdlog_cpm_args
                          BUILD_EXPORT_SET thirdparty_exports INSTALL_EXPORT_SET thirdparty_exports)

  include(${rapids-cmake-dir}/cpm/find.cmake)

  rapids_cpm_find(spdlog ${spdlog_version}
                  GLOBAL_TARGETS spdlog::spdlog
                  BUILD_EXPORT_SET thirdparty_exports
                  INSTALL_EXPORT_SET thirdparty_exports
                  CPM_ARGS ${spdlog_cpm_args}
                  OPTIONS "SPDLOG_INSTALL ON" "SPDLOG_BUILD_EXAMPLE OFF" "SPDLOG_BUILD_TESTS OFF"
                          "SPDLOG_FMT_EXTERNAL ON" "CMAKE_POSITION_INDEPENDENT_CODE ON")
endfunction()

find_and_configure_spdlog()
