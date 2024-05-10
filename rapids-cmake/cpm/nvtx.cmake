#=============================================================================
# Copyright (c) 2024, NVIDIA CORPORATION.
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
rapids_cpm_nvtx
---------------

.. versionadded:: v24.06.00

Allow projects to find `NVTX3` via `CPM` with built-in tracking of dependencies
for correct export support.

Uses the version of nvtx :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_nvtx( [BUILD_EXPORT_SET <export-name>]
                   [INSTALL_EXPORT_SET <export-name>]
                   [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: nvtx
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  nvtx3-c, nvtx3-cpp targets will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`NVTX3_SOURCE_DIR` is set to the path to the source directory of nvtx.
  :cmake:variable:`NVTX3_BINARY_DIR` is set to the path to the build directory of nvtx.
  :cmake:variable:`NVTX3_ADDED`      is set to a true value if nvtx has not been added before.
  :cmake:variable:`NVTX3_VERSION`    is set to the version of nvtx specified by the versions.json.

#]=======================================================================]
function(rapids_cpm_nvtx)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.nvtx")

  set(to_install OFF)
  if(INSTALL_EXPORT_SET IN_LIST ARGN)
    set(to_install ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(nvtx version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(nvtx ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(NVTX3 ${version} ${ARGN}
                  GLOBAL_TARGETS nvtx3-c nvtx3-cpp
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow} ${patch_command} SOURCE_SUBDIR c
                  EXCLUDE_FROM_ALL ${exclude})

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(NVTX3)

  # Propagate up variables that CPMFindPackage provide
  set(NVTX3_SOURCE_DIR "${NVTX3_SOURCE_DIR}" PARENT_SCOPE)
  set(NVTX3_BINARY_DIR "${NVTX3_BINARY_DIR}" PARENT_SCOPE)
  set(NVTX3_ADDED "${NVTX3_ADDED}" PARENT_SCOPE)
  set(NVTX3_VERSION ${version} PARENT_SCOPE)

endfunction()
