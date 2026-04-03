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
include(rapids-cpm)
include(rapids-cuda)

rapids_cuda_init_architectures(offline_build_example)

# rapids-pre-commit-hooks: disable-next-line[verify-hardcoded-version]
project(offline_build_example VERSION 1.0 LANGUAGES CXX CUDA)

rapids_cmake_build_type(Release)

# Initialize CPM. CPM_SOURCE_CACHE and CPM_USE_LOCAL_PACKAGES can be passed on the command line to
# control offline behavior.
rapids_cpm_init()

# Fetch CCCL
include(${rapids-cmake-dir}/cpm/cccl.cmake)
rapids_cpm_cccl()

# Fetch RMM
include(${rapids-cmake-dir}/cpm/rmm.cmake)
rapids_cpm_rmm()

# Create a simple CUDA executable
add_executable(offline_build_example main.cu)

set_target_properties(offline_build_example PROPERTIES CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON
                                                       CUDA_STANDARD 20 CUDA_STANDARD_REQUIRED ON)

target_link_libraries(offline_build_example PRIVATE Thrust::Thrust rmm::rmm)
