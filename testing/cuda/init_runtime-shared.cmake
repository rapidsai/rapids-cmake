#=============================================================================
# Copyright (c) 2021-2025, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================
include(${rapids-cmake-dir}/cuda/init_runtime.cmake)

rapids_cuda_init_runtime(USE_STATIC FALSE)
if(NOT CMAKE_CUDA_RUNTIME_LIBRARY STREQUAL "SHARED")
  message(FATAL_ERROR "rapids_cuda_init_runtime didn't correctly set CMAKE_CUDA_RUNTIME_LIBRARY")
endif()
