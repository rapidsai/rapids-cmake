#=============================================================================
# Copyright (c) 2025, NVIDIA CORPORATION.
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
rapids_cpm_rapids_logger
------------------------

.. versionadded:: v25.02.00

Allow projects to build `rapids-logger` via `CPM`.

Uses the version of rapids-logger :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_rapids_logger( [BUILD_EXPORT_SET <export-name>]
                            [INSTALL_EXPORT_SET <export-name>]
                            [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: logger
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  rapids_logger::rapids_logger target will be created

#]=======================================================================]
function(rapids_cpm_rapids_logger)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rapids_logger")

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(rapids_logger version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(rapids_logger ${version} patch_command build_patch_only)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(rapids_logger ${version} ${ARGN} ${build_patch_only}
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow} ${patch_command}
                  OPTIONS "BUILD_TESTS OFF")

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(logger)

  # Propagate up variables that CPMFindPackage provide
  set(rapids_logger_SOURCE_DIR "${rapids_logger_SOURCE_DIR}" PARENT_SCOPE)
  set(rapids_logger_BINARY_DIR "${rapids_logger_BINARY_DIR}" PARENT_SCOPE)
  set(rapids_logger_ADDED "${rapids_logger_ADDED}" PARENT_SCOPE)
  set(rapids_logger_VERSION ${version} PARENT_SCOPE)
endfunction()
