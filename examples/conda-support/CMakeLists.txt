# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

cmake_minimum_required(VERSION 3.30.4 FATAL_ERROR)

# When running under rapids-cmake testing infrastructure, rapids-cmake-dir is already set and we
# should use the local version instead of downloading RAPIDS.cmake
if(NOT DEFINED rapids-cmake-dir)
  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
    file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/main/RAPIDS.cmake
         ${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
  endif()
  set(rapids-cmake-branch main)
  include(${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
else()
  # Test mode: Set up CMAKE_MODULE_PATH to use local rapids-cmake
  if(NOT "${rapids-cmake-dir}" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${rapids-cmake-dir}")
  endif()
endif()

include(rapids-cmake)
include(rapids-cuda)

rapids_cuda_init_architectures(conda_support_example)

project(conda_support_example VERSION 1.0 LANGUAGES CXX CUDA)

rapids_cmake_build_type(Release)

# Create conda environment support target This target provides: - Conda include directories (as
# SYSTEM to match conda behavior) - Conda library directories - Proper rpath-link settings for conda
# environments - Debug build optimization override (-O0 instead of conda's -O2) - File prefix
# remapping for reproducible builds
rapids_cmake_support_conda_env(conda_env MODIFY_PREFIX_PATH)

# Create a simple CUDA library
add_library(conda_support_lib SHARED lib.cu)

set_target_properties(conda_support_lib
                      PROPERTIES CXX_STANDARD 17
                                 CXX_STANDARD_REQUIRED ON
                                 CUDA_STANDARD 17
                                 CUDA_STANDARD_REQUIRED ON
                                 POSITION_INDEPENDENT_CODE ON)

# Link the conda environment target if it exists The target is only created when running in a conda
# environment
if(TARGET conda_env)
  target_link_libraries(conda_support_lib PRIVATE conda_env)
  message(STATUS "Conda environment support enabled")
else()
  message(STATUS "Not in conda environment - conda support target not created")
endif()

# Create an executable that uses the library
add_executable(conda_support_example main.cu)
target_link_libraries(conda_support_example PRIVATE conda_support_lib)

set_target_properties(conda_support_example PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED ON
                                                       CUDA_STANDARD 17 CUDA_STANDARD_REQUIRED ON)

if(TARGET conda_env)
  target_link_libraries(conda_support_example PRIVATE conda_env)
endif()
