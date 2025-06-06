#=============================================================================
# Copyright (c) 2024-2025, NVIDIA CORPORATION.
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
rapids_cpm_nvtx3
----------------

.. versionadded:: v24.06.00

Allow projects to find `nvtx3` via `CPM` with built-in tracking of dependencies
for correct export support.

Uses the version of nvtx3 :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_nvtx3( [BUILD_EXPORT_SET <export-name>]
                    [INSTALL_EXPORT_SET <export-name>]
                    [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: nvtx3
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  nvtx3::nvtx3-c, nvtx3::nvtx3-cpp targets will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`nvtx3_SOURCE_DIR` is set to the path to the source directory of nvtx3.
  :cmake:variable:`nvtx3_BINARY_DIR` is set to the path to the build directory of nvtx3.
  :cmake:variable:`nvtx3_ADDED`      is set to a true value if nvtx3 has not been added before.
  :cmake:variable:`nvtx3_VERSION`    is set to the version of nvtx3 specified by the versions.json.

#]=======================================================================]
function(rapids_cpm_nvtx3)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.nvtx3")

  set(options)
  set(one_value BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  # Fix up _RAPIDS_UNPARSED_ARGUMENTS to have EXPORT_SETS as this is need for rapids_cpm_find
  if(_RAPIDS_INSTALL_EXPORT_SET)
    list(APPEND _RAPIDS_EXPORT_ARGUMENTS INSTALL_EXPORT_SET ${_RAPIDS_INSTALL_EXPORT_SET})
  endif()
  if(_RAPIDS_BUILD_EXPORT_SET)
    list(APPEND _RAPIDS_EXPORT_ARGUMENTS BUILD_EXPORT_SET ${_RAPIDS_BUILD_EXPORT_SET})
  endif()
  set(_RAPIDS_UNPARSED_ARGUMENTS ${_RAPIDS_EXPORT_ARGUMENTS})

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(nvtx3 version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(nvtx3 ${version} patch_command build_patch_only)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(nvtx3 ${version} ${ARGN} ${build_patch_only}
                  GLOBAL_TARGETS nvtx3-c nvtx3-cpp
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow} ${patch_command} SOURCE_SUBDIR c
                  EXCLUDE_FROM_ALL ${exclude}
                  OPTIONS "NVTX3_INSTALL ON")

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(nvtx3)

  # Propagate up variables that CPMFindPackage provide
  set(nvtx3_SOURCE_DIR "${nvtx3_SOURCE_DIR}" PARENT_SCOPE)
  set(nvtx3_BINARY_DIR "${nvtx3_BINARY_DIR}" PARENT_SCOPE)
  set(nvtx3_ADDED "${nvtx3_ADDED}" PARENT_SCOPE)
  set(nvtx3_VERSION ${version} PARENT_SCOPE)

endfunction()
