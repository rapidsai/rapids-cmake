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

# Verify that rapids_cpm_package_info generates correct CPM arguments
include("${rapids-cmake-dir}/cpm/detail/package_info.cmake")

# Test tarball package - should use URL
rapids_cpm_package_info(test_tarball_pkg VERSION_VAR version CPM_VAR cpm_args)

list(FIND cpm_args "URL" url_index)
if(url_index EQUAL -1)
  message(FATAL_ERROR "CPM args should contain 'URL' for use_github_tarball package.\nGot: ${cpm_args}"
  )
endif()

list(FIND cpm_args "GIT_REPOSITORY" git_repo_index)
if(NOT git_repo_index EQUAL -1)
  message(FATAL_ERROR "CPM args should NOT contain 'GIT_REPOSITORY' for use_github_tarball package.\nGot: ${cpm_args}"
  )
endif()

list(FIND cpm_args "GIT_TAG" git_tag_index)
if(NOT git_tag_index EQUAL -1)
  message(FATAL_ERROR "CPM args should NOT contain 'GIT_TAG' for use_github_tarball package.\nGot: ${cpm_args}"
  )
endif()

list(FIND cpm_args "GIT_SHALLOW" git_shallow_index)
if(NOT git_shallow_index EQUAL -1)
  message(FATAL_ERROR "CPM args should NOT contain 'GIT_SHALLOW' for use_github_tarball package.\nGot: ${cpm_args}"
  )
endif()

# Verify the URL value is correct
math(EXPR url_value_index "${url_index} + 1")
list(GET cpm_args ${url_value_index} url_value)
set(expected_url "https://github.com/NVIDIA/cccl/archive/abc123def456.tar.gz")
if(NOT url_value STREQUAL expected_url)
  message(FATAL_ERROR "URL value should be tarball URL.\nExpected: ${expected_url}\nGot: ${url_value}"
  )
endif()

# Test git package - should use GIT_REPOSITORY/GIT_TAG
rapids_cpm_package_info(test_git_pkg VERSION_VAR version CPM_VAR cpm_args)

list(FIND cpm_args "GIT_REPOSITORY" git_repo_index)
if(git_repo_index EQUAL -1)
  message(FATAL_ERROR "CPM args should contain 'GIT_REPOSITORY' for git package.\nGot: ${cpm_args}")
endif()

list(FIND cpm_args "GIT_TAG" git_tag_index)
if(git_tag_index EQUAL -1)
  message(FATAL_ERROR "CPM args should contain 'GIT_TAG' for git package.\nGot: ${cpm_args}")
endif()

list(FIND cpm_args "URL" url_index)
if(NOT url_index EQUAL -1)
  message(FATAL_ERROR "CPM args should NOT contain 'URL' for git package.\nGot: ${cpm_args}")
endif()
