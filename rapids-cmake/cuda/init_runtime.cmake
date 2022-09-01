#=============================================================================
# Copyright (c) 2021, NVIDIA CORPORATION.
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
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cuda_init_runtime
-------------------------------

.. versionadded:: v21.06.00

Establish what CUDA runtime library should be propagated

  .. code-block:: cmake

    rapids_cuda_init_runtime( USE_STATIC (TRUE|FALSE) )

  Establishes what CUDA runtime will be used, if not already explicitly
  specified via :cmake:variable:`CMAKE_CUDA_RUNTIME_LIBRARY` variable.

  When `USE_STATIC TRUE` is provided all target will link to a
    statically-linked CUDA runtime library.

  When `USE_STATIC FALSE` is provided all target will link to a
    shared-linked CUDA runtime library.


#]=======================================================================]
function(rapids_cuda_init_runtime use_static value)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cuda.init_runtime")

  if(NOT DEFINED CMAKE_CUDA_RUNTIME_LIBRARY)
    if(${value})
      # Control legacy FindCUDA.cmake behavior too
      set(CUDA_USE_STATIC_CUDA_RUNTIME ON PARENT_SCOPE)
      set(CMAKE_CUDA_RUNTIME_LIBRARY STATIC PARENT_SCOPE)
    else()
      # Control legacy FindCUDA.cmake behavior too
      set(CUDA_USE_STATIC_CUDA_RUNTIME OFF PARENT_SCOPE)
      set(CMAKE_CUDA_RUNTIME_LIBRARY STATIC PARENT_SCOPE)
    endif()
  endif()
endfunction()
