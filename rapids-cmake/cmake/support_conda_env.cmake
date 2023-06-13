#=============================================================================
# Copyright (c) 2021-2023, NVIDIA CORPORATION.
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
rapids_cmake_support_conda_env
------------------------------

.. versionadded:: v21.06.00

Establish a target that holds the CONDA include and link directories.

  .. code-block:: cmake

    rapids_cmake_support_conda_env( <target_name> [MODIFY_PREFIX_PATH] )

Creates a global interface target called `target_name` that holds
the CONDA include and link directories, when executed.

Also offers the ability to modify :cmake:variable:`CMAKE_PREFIX_PATH <cmake:variable:CMAKE_PREFIX_PATH>` to
include the following paths based on the current CONDA environment:

  - `PREFIX`
  - `BUILD_PREFIX`
  - `CONDA_PREFIX`

  .. versionadded:: v23.08.00

    - `PREFIX`/targets/<cuda_target_platform>/

``MODIFY_PREFIX_PATH``
    When in a conda build environment the contents of `$ENV{PREFIX}`,
    `$ENV{PREFIX}`/targets/<cuda_target_platform>/`, and `$ENV{BUILD_PREFIX}` will be inserted to the
    front of :cmake:variable:`CMAKE_PREFIX_PATH <cmake:variable:CMAKE_PREFIX_PATH>`.

    When in a conda environment the contents of `$ENV{CONDA_PREFIX}` will be inserted to
    the front of :cmake:variable:`CMAKE_PREFIX_PATH <cmake:variable:CMAKE_PREFIX_PATH>`.

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`CMAKE_PREFIX_PATH <cmake:variable:CMAKE_PREFIX_PATH>` will be modified when `MODIFY_PREFIX_PATH` is provided
  and called from a conda environment.

Result Targets
^^^^^^^^^^^^^^^^
  `target_name` target will be created only if called from a conda environment.

#]=======================================================================]
# cmake-lint: disable=R0912,R0915
function(rapids_cmake_support_conda_env target)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cmake.support_conda_env")

  # target exists early terminate
  if(TARGET ${target})
    return()
  endif()

  if("$ENV{CONDA_BUILD}" STREQUAL "1")
    set(in_conda_build True)
  elseif(DEFINED ENV{CONDA_PREFIX})
    set(in_conda_prefix True)
  endif()

  if(in_conda_build OR in_conda_prefix)

    if(ARGV1 STREQUAL "MODIFY_PREFIX_PATH")
      set(modify_prefix_path TRUE)
    endif()

    add_library(${target} INTERFACE)
    set(prefix_paths)

    if(in_conda_build)
      # For conda-build we add the host conda environment prefix to the cmake search paths so that
      # raw `find_file` or `find_library` calls will find CUDA components in the host environment
      set(target_platform $ENV{cross_target_platform}) # when target != cross_target
      if(NOT target_platform)
        set(target_platform $ENV{target_platform})
      endif()
      if("${target_platform}" STREQUAL "linux-64")
        set(targetsDir "targets/x86_64-linux")
      elseif("${target_platform}" STREQUAL "linux-ppc64le")
        set(targetsDir "targets/ppc64le-linux")
      elseif("${target_platform}" STREQUAL "linux-aarch64")
        set(targetsDir "targets/sbsa-linux")
      endif()

      target_include_directories(${target} INTERFACE "$ENV{PREFIX}/include"
                                                     "$ENV{BUILD_PREFIX}/include")
      target_link_directories(${target} INTERFACE "$ENV{PREFIX}/lib" "$ENV{BUILD_PREFIX}/lib")

      if(DEFINED CMAKE_SHARED_LIBRARY_RPATH_LINK_CUDA_FLAG
         OR DEFINED CMAKE_SHARED_LIBRARY_RPATH_LINK_CXX_FLAG)
        if(DEFINED targetsDir)
          target_link_options(${target} INTERFACE
                              "$<HOST_LINK:SHELL:LINKER:-rpath-link=$ENV{PREFIX}/${targetsDir}/lib>"
          )
        endif()
        target_link_options(${target} INTERFACE
                            "$<HOST_LINK:SHELL:LINKER:-rpath-link=$ENV{PREFIX}/lib>")
        target_link_options(${target} INTERFACE
                            "$<HOST_LINK:SHELL:LINKER:-rpath-link=$ENV{BUILD_PREFIX}/lib>")
      endif()

      if(modify_prefix_path)
        list(PREPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}" "$ENV{BUILD_PREFIX}")
        if(DEFINED targetsDir)
          list(PREPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/${targetsDir}")
        endif()
        set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
        message(VERBOSE "Conda build detected, CMAKE_PREFIX_PATH set to: ${CMAKE_PREFIX_PATH}")
      endif()

    elseif(in_conda_prefix)
      target_include_directories(${target} INTERFACE "$ENV{CONDA_PREFIX}/include")
      target_link_directories(${target} INTERFACE "$ENV{CONDA_PREFIX}/lib")
      if(DEFINED CMAKE_SHARED_LIBRARY_RPATH_LINK_CUDA_FLAG
         OR DEFINED CMAKE_SHARED_LIBRARY_RPATH_LINK_CXX_FLAG)
        target_link_options(${target} INTERFACE
                            "$<HOST_LINK:SHELL:LINKER:-rpath-link=$ENV{CONDA_PREFIX}/lib>")
      endif()

      if(modify_prefix_path)
        list(PREPEND CMAKE_PREFIX_PATH "$ENV{CONDA_PREFIX}")
        set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
        message(VERBOSE
                "Conda environment detected, CMAKE_PREFIX_PATH set to: ${CMAKE_PREFIX_PATH}")
      endif()
    endif()
  endif()
endfunction()
