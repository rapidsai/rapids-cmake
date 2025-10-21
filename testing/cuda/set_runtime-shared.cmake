#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cuda/set_runtime.cmake)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/empty.cpp" " ")
add_library(uses_cuda SHARED ${CMAKE_CURRENT_BINARY_DIR}/empty.cpp)
rapids_cuda_set_runtime(uses_cuda USE_STATIC FALSE)

get_target_property(runtime_state uses_cuda CUDA_RUNTIME_LIBRARY)
if(NOT runtime_state STREQUAL "Shared")
  message(FATAL_ERROR "rapids_cuda_set_runtime didn't correctly set CUDA_RUNTIME_LIBRARY")
endif()

get_target_property(linked_libs uses_cuda LINK_LIBRARIES)
if(NOT "$<TARGET_NAME_IF_EXISTS:CUDA::cudart>" IN_LIST linked_libs)
  message(FATAL_ERROR "rapids_cuda_set_runtime didn't privately link to CUDA::cudart")
endif()
