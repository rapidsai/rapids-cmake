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
rapids_cpm_init
-------------------

.. versionadded:: v21.06.00

Establish the `CPM` and preset package infrastructure for the project.

.. code-block:: cmake

  rapids_cpm_init()

The CPM module will be downloaded based on the state of :cmake:variable:`CPM_SOURCE_CACHE` and
:cmake:variable:`ENV{CPM_SOURCE_CACHE}`. This allows multiple nested projects to share the
same download of CPM. If those variables aren't set the file will be cached
in the build tree of the calling project

.. note::
  Must be called before any invocation of :cmake:command:`rapids_cpm_find`.

#]=======================================================================]
function(rapids_cpm_init)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.init")

  include("${rapids-cmake-dir}/cpm/detail/load_preset_versions.cmake")
  rapids_cpm_load_preset_versions()

  set(CPM_DOWNLOAD_VERSION 7644c3a40fc7889f8dee53ce21e85dc390b883dc) # 0.32.1

  if(CPM_SOURCE_CACHE)
    # Expand relative path. This is important if the provided path contains a tilde (~)
    cmake_path(ABSOLUTE_PATH CPM_SOURCE_CACHE)
    set(CPM_DOWNLOAD_LOCATION "${CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
  elseif(DEFINED ENV{CPM_SOURCE_CACHE})
    set(CPM_DOWNLOAD_LOCATION "$ENV{CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
  else()
    set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
  endif()

  if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
    message(VERBOSE "Downloading CPM.cmake to ${CPM_DOWNLOAD_LOCATION}")
    file(DOWNLOAD
         https://raw.githubusercontent.com/cpm-cmake/CPM.cmake/${CPM_DOWNLOAD_VERSION}/cmake/CPM.cmake
         ${CPM_DOWNLOAD_LOCATION})
  endif()

  include(${CPM_DOWNLOAD_LOCATION})

endfunction()
