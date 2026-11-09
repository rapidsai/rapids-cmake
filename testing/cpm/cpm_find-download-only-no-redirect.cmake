# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/find.cmake)

rapids_cpm_init()

set(CPM_DOWNLOAD_dlpack ON)

rapids_cpm_find(dlpack 1.3
                CPM_ARGS
                GIT_REPOSITORY https://github.com/dmlc/dlpack.git
                GIT_TAG v1.3
                GIT_SHALLOW TRUE
                DOWNLOAD_ONLY ON)

if(EXISTS "${CMAKE_FIND_PACKAGE_REDIRECTS_DIR}/dlpack-config.cmake")
  message(FATAL_ERROR "DOWNLOAD_ONLY packages should not get a find_package redirect")
endif()

# A later find_package must still reach the project's own find module
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/modules/Finddlpack.cmake"
     "add_library(dlpack::from_find_module INTERFACE IMPORTED)\nset(dlpack_FOUND TRUE)\n")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_BINARY_DIR}/modules")
find_package(dlpack MODULE REQUIRED)
if(NOT TARGET dlpack::from_find_module)
  message(FATAL_ERROR "find_package(dlpack) was redirected away from Finddlpack.cmake")
endif()
