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
include(${rapids-cmake-dir}/cuda/enable_fatbin_compression.cmake)

# Initialize CUDA architectures before project() call
rapids_cuda_init_architectures(cuda_features_example)

project(cuda_features_example VERSION 1.0 LANGUAGES CXX CUDA)

option(CUDA_STATIC_RUNTIME "Use CUDA static runtime" OFF)

# Set a default build type if none was specified
rapids_cmake_build_type(Release)

# Set the CUDA runtime that CUDA targets will use
rapids_cuda_init_runtime(USE_STATIC ${CUDA_STATIC_RUNTIME})

# Create a simple CUDA executable
add_executable(cuda_features_example main.cu)

set_target_properties(cuda_features_example PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED ON
                                                       CUDA_STANDARD 17 CUDA_STANDARD_REQUIRED ON)

# Enable fatbin compression on the target
rapids_cuda_enable_fatbin_compression(TARGET cuda_features_example)
