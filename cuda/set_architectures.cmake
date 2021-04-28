#=============================================================================
# Copyright (c) 2018-2021, NVIDIA CORPORATION.
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
rapids_cuda_set_architectures
-------------------------------

.. versionadded:: 0.20

Finishes setting up :variable:`CMAKE_CUDA_ARCHITECTURES` based on the output
state of `rapids_cuda_init_architectures`.

Note: Is automatically called by `rapids_cuda_init_architectures`

.. command:: rapids_cuda_set_architectures

  .. code-block:: cmake

    rapids_cuda_set_architectures( (NATIVE|ALL) )

  Establishes what CUDA architectures that will be compiled for.

  Note: Is automatically called by `rapids_cuda_init_architectures`

  ``NATIVE``:
    When passed NATIVE as the first parameter will compile for all
    GPU architectures present on the current machine. Requires that
    the CUDA language be enabled for the current CMake project.

  ``ALL``:
    When passed ALL will compile for all supported RAPIDS GPU architectures


Result Variables
^^^^^^^^^^^^^^^^

  ``CMAKE_CUDA_ARCHITECTURES`` will exist and set to the list of architectures
  that should be compiled for

#]=======================================================================]
function(rapids_cuda_set_architectures mode)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cuda.set_architectures")

  set(supported_archs "60" "62" "70" "72" "75" "80" "86")

  # Check for embedded vs workstation architectures
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
    # This is being built for Linux4Tegra or SBSA ARM64
    list(REMOVE_ITEM supported_archs "60" "70")
  else()
    # This is being built for an x86 or x86_64 architecture
    list(REMOVE_ITEM supported_archs "62" "72")
  endif()


  if(CMAKE_CUDA_COMPILER_ID STREQUAL "NVIDIA" AND
     CMAKE_CUDA_COMPILER_VERSION VERSION_LESS 11.1.0)
    list(REMOVE_ITEM supported_archs "86")
  endif()

  if(${mode} STREQUAL "ALL")

    # CMake architecture list entry of "80" means to build compute and sm. What we want is for the
    # newest arch only to build that way while the rest built only for sm.
    list(POP_BACK supported_archs latest_arch)
    list(TRANSFORM supported_archs APPEND "-real")
    list(APPEND supported_archs ${latest_arch})

    set(CMAKE_CUDA_ARCHITECTURES ${supported_archs} PARENT_SCOPE)
  elseif(${mode} STREQUAL "NATIVE")
    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/detect_architectures.cmake)
    rapids_cuda_detect_architectures(supported_archs CMAKE_CUDA_ARCHITECTURES)

    list(TRANSFORM CMAKE_CUDA_ARCHITECTURES APPEND "-real")
    set(CMAKE_CUDA_ARCHITECTURES ${CMAKE_CUDA_ARCHITECTURES} PARENT_SCOPE)
  endif()

endfunction()
