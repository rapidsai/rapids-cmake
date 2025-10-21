#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021-2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cuda/set_architectures.cmake)

enable_language(CUDA)
rapids_cuda_set_architectures(RAPIDS)

if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
  message(FATAL_ERROR "CMAKE_CUDA_ARCHITECTURES should exist after calling rapids_cuda_set_architectures()"
  )
endif()

include("${rapids-cmake-testing-dir}/cuda/validate-cuda-rapids.cmake")
