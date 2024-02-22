#=============================================================================
# Copyright (c) 2021-2024, NVIDIA CORPORATION.
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
---------------

.. versionadded:: v21.06.00

Establish the `CPM` and preset package infrastructure for the project.

.. code-block:: cmake

  rapids_cpm_init( [OVERRIDE <json_override_file_path> ]
                   [GENERATE_PINNED_VERSIONS]
                   )

The CPM module will be downloaded based on the state of :cmake:variable:`CPM_SOURCE_CACHE` and
:cmake:variable:`ENV{CPM_SOURCE_CACHE}`. This allows multiple nested projects to share the
same download of CPM. If those variables aren't set the file will be cached
in the build tree of the calling project

.. versionadded:: v24.04.00
  As part of establishing rapids-cmake CPM the :cmake:command:`rapids_cpm_init` command
  will call :cmake:command:`rapids_cpm_generate_pinned_versions` to automatically generate
  `<CMAKE_BINARY_DIR>/rapids-cmake/pinned_versions.json` which will contain all the exact git SHAs
  used to build cpm dependencies.

.. versionadded:: v21.10.00
  ``OVERRIDE``
  Override the `CPM` preset package information for the project. The user provided
  json file must follow the `versions.json` format, which is :ref:`documented here<cpm_version_format>`.

  If the override file doesn't specify a value or package entry the default
  version will be used.

.. versionadded:: v24.04.00
  ```
  GENERATE_PINNED_VERSIONS
  ```
  Generates a json file with all cpm dependencies with pinned version values.
  This allows for reproducible builds using the exact same state.
  The pinning file will be located at `<CMAKE_BINARY_DIR>/rapids-cmake/pinned_versions.json`

.. note::
  Must be called before any invocation of :cmake:command:`rapids_cpm_find`.

#]=======================================================================]
function(rapids_cpm_init)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.init")

  set(_rapids_options GENERATE_PINNED_VERSIONS)
  set(_rapids_one_value OVERRIDE)
  set(_rapids_multi_value)
  cmake_parse_arguments(_RAPIDS "${_rapids_options}" "${_rapids_one_value}"
                        "${_rapids_multi_value}" ${ARGN})

  include("${rapids-cmake-dir}/cpm/detail/load_preset_versions.cmake")
  rapids_cpm_load_preset_versions()

  if(_RAPIDS_OVERRIDE)
    include("${rapids-cmake-dir}/cpm/package_override.cmake")
    rapids_cpm_package_override("${_RAPIDS_OVERRIDE}")
  endif()

  if(_RAPIDS_GENERATE_PINNED_VERSIONS)
    include("${rapids-cmake-dir}/cpm/generate_pinned_versions.cmake")
    rapids_cpm_generate_pinned_versions(
      OUTPUT "${CMAKE_BINARY_DIR}/rapids-cmake/pinned_versions.json")
  endif()

  include("${rapids-cmake-dir}/cpm/detail/download.cmake")
  rapids_cpm_download()

  # Propagate up any modified local variables that CPM has changed.
  #
  # Push up the modified CMAKE_MODULE_PATh to allow `find_package` calls to find packages that CPM
  # already added.
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
endfunction()
