#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021-2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cuda/init_runtime.cmake)

rapids_cuda_init_runtime(USE_STATIC FALSE)
if(NOT CMAKE_CUDA_RUNTIME_LIBRARY STREQUAL "SHARED")
  message(FATAL_ERROR "rapids_cuda_init_runtime didn't correctly set CMAKE_CUDA_RUNTIME_LIBRARY")
endif()
