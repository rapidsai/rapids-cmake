# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(CMakePackageConfigHelpers)

function(make_fake_package_config package target)
  set(package_dir "${CMAKE_CURRENT_BINARY_DIR}/${package}")
  file(MAKE_DIRECTORY "${package_dir}")
  file(WRITE "${package_dir}/${package}Config.cmake"
       "add_library(${target} INTERFACE IMPORTED)\nset(${package}_FOUND TRUE)\n")
  write_basic_package_version_file("${package_dir}/${package}ConfigVersion.cmake" VERSION 1.0
                                   COMPATIBILITY SameMajorVersion)

  list(PREPEND CMAKE_PREFIX_PATH "${package_dir}")
  set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
endfunction()
