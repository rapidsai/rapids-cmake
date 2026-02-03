# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

# Example function
function(find_and_configure_fmt)
  include(${rapids-cmake-dir}/cpm/package_override.cmake)
  include(${rapids-cmake-dir}/cpm/detail/package_info.cmake)

  rapids_cpm_package_override(${CMAKE_CURRENT_LIST_DIR}/fmt_version.json)

  rapids_cpm_package_info(fmt VERSION_VAR fmt_version CPM_VAR fmt_cpm_args BUILD_EXPORT_SET
                          thirdparty_exports INSTALL_EXPORT_SET thirdparty_exports)

  include(${rapids-cmake-dir}/cpm/find.cmake)

  rapids_cpm_find(fmt ${fmt_version}
                  GLOBAL_TARGETS fmt::fmt
                  BUILD_EXPORT_SET thirdparty_exports
                  INSTALL_EXPORT_SET thirdparty_exports
                  CPM_ARGS ${fmt_cpm_args}
                  OPTIONS "FMT_INSTALL ON" "CMAKE_POSITION_INDEPENDENT_CODE ON")
endfunction()

find_and_configure_fmt()
