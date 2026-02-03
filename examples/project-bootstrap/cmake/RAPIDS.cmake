# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

cmake_minimum_required(VERSION 3.30.4 FATAL_ERROR)

# When running under rapids-cmake testing infrastructure, rapids-cmake-dir is already set In this
# case, skip downloading and just use the provided local version
if(DEFINED rapids-cmake-dir)
  if(NOT "${rapids-cmake-dir}" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${rapids-cmake-dir}")
  endif()
  return()
endif()

# Set default repository if not specified
if(NOT rapids-cmake-repo)
  set(rapids-cmake-repo rapidsai/rapids-cmake)
endif()

# Set default branch if not specified (should be set by rapids_config.cmake)
if(NOT rapids-cmake-branch)
  set(rapids-cmake-branch "release/${rapids-cmake-version}")
endif()

# Construct URL for FetchContent
if(NOT rapids-cmake-url)
  set(rapids-cmake-url "https://github.com/${rapids-cmake-repo}/")

  # Determine what to clone: SHA > tag > branch Support both Git-based and ZIP archive downloads
  if(rapids-cmake-fetch-via-git)
    # Git clone mode (slower, but supports uncommitted changes)
    if(rapids-cmake-sha)
      set(rapids-cmake-value-to-clone "${rapids-cmake-sha}")
    elseif(rapids-cmake-tag)
      set(rapids-cmake-value-to-clone "${rapids-cmake-tag}")
    else()
      set(rapids-cmake-value-to-clone "${rapids-cmake-branch}")
    endif()
  else()
    # ZIP archive mode (faster, default)
    if(rapids-cmake-sha)
      set(rapids-cmake-value-to-clone "archive/${rapids-cmake-sha}.zip")
    elseif(rapids-cmake-tag)
      set(rapids-cmake-value-to-clone "archive/refs/tags/${rapids-cmake-tag}.zip")
    else()
      set(rapids-cmake-value-to-clone "archive/refs/heads/${rapids-cmake-branch}.zip")
    endif()
  endif()
endif()

# Use FetchContent to download rapids-cmake
include(FetchContent)

if(rapids-cmake-fetch-via-git)
  # Git clone (use when you need uncommitted changes or specific SHAs)
  FetchContent_Declare(rapids-cmake GIT_REPOSITORY "${rapids-cmake-url}"
                       GIT_TAG "${rapids-cmake-value-to-clone}")
else()
  # ZIP archive (default, faster)
  string(APPEND rapids-cmake-url "${rapids-cmake-value-to-clone}")
  FetchContent_Declare(rapids-cmake URL "${rapids-cmake-url}")
endif()

# Populate rapids-cmake and add to CMAKE_MODULE_PATH
FetchContent_GetProperties(rapids-cmake)
if(rapids-cmake_POPULATED)
  # Already populated (possibly by another project)
  if(NOT "${rapids-cmake-dir}" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${rapids-cmake-dir}")
  endif()
else()
  # Download and populate
  FetchContent_MakeAvailable(rapids-cmake)
endif()
