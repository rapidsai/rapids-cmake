# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2024-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)
project(rapids-cpm_find-patch-command-project LANGUAGES CXX)

include(${rapids-cmake-dir}/cpm/init.cmake)
rapids_cpm_init()

include(${rapids-cmake-dir}/cpm/package_override.cmake)
rapids_cpm_package_override(${CMAKE_CURRENT_SOURCE_DIR}/override.json)

include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
rapids_cpm_package_details_internal(GTest version repository tag src_subdir shallow exclude)

set(deps_dir "${CMAKE_CURRENT_BINARY_DIR}/_gtest_dep")
if(NOT EXISTS "${deps_dir}")
  file(MAKE_DIRECTORY "${deps_dir}")
  file(DOWNLOAD "${repository}" "${deps_dir}/gtest.tar.gz")
  file(ARCHIVE_EXTRACT INPUT "${deps_dir}/gtest.tar.gz" DESTINATION "${deps_dir}")
  file(GLOB extracted_dir "${deps_dir}/googletest-*")
  file(RENAME "${extracted_dir}" "${deps_dir}/googletest")
endif()

set(gtest_dir "${deps_dir}/googletest")
list(APPEND CMAKE_PREFIX_PATH "${gtest_dir}")

include(${rapids-cmake-dir}/cpm/gtest.cmake)
rapids_cpm_gtest()

if(NOT "${GTest_ADDED}")
  message(FATAL_ERROR "The found repo was used rather than downloading and patching a new version")
endif()

# Verify that the file inserted by the .diff patch exists, proving that patch -p1 (in tarball mode)
# correctly applied a .diff file.
if(NOT EXISTS "${GTest_SOURCE_DIR}/git_file_1.txt")
  message(FATAL_ERROR "failed to apply GTest diff patch")
endif()
