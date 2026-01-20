# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2025-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/package_override.cmake)

rapids_cpm_init()

# Need to write out an override file with use_github_tarball
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/override.json
     [=[
{
  "packages": {
    "test_tarball_pkg": {
      "version": "1.0.0",
      "git_url": "https://github.com/NVIDIA/cccl.git",
      "git_tag": "abc123def456",
      "use_github_tarball": true
    },
    "test_git_pkg": {
      "version": "2.0.0",
      "git_url": "https://github.com/NVIDIA/other.git",
      "git_tag": "xyz789"
    }
  }
}
  ]=])

rapids_cpm_package_override(${CMAKE_CURRENT_BINARY_DIR}/override.json)

# Verify that use_github_tarball constructs the correct URL and clears the tag
include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")

rapids_cpm_package_details_internal(test_tarball_pkg version url tag src_subdir shallow exclude)

# Verify URL is constructed as tarball URL
set(expected_url "https://github.com/NVIDIA/cccl/archive/abc123def456.tar.gz")
if(NOT url STREQUAL expected_url)
  message(FATAL_ERROR "use_github_tarball should construct tarball URL.\nExpected: ${expected_url}\nGot: ${url}"
  )
endif()

# Verify tag is empty (signals URL-based fetching) Use truthiness check - empty string evaluates to
# false in CMake
if(tag)
  message(FATAL_ERROR "use_github_tarball should set tag to empty. Got: '${tag}'")
endif()

# Verify version is still correct
if(NOT version STREQUAL "1.0.0")
  message(FATAL_ERROR "version should be 1.0.0. Got: ${version}")
endif()

# Verify that packages without use_github_tarball still use git
rapids_cpm_package_details_internal(test_git_pkg version url tag src_subdir shallow exclude)

if(NOT url STREQUAL "https://github.com/NVIDIA/other.git")
  message(FATAL_ERROR "git_url should be preserved for non-tarball packages. Got: ${url}")
endif()

if(NOT tag STREQUAL "xyz789")
  message(FATAL_ERROR "git_tag should be preserved for non-tarball packages. Got: ${tag}")
endif()
