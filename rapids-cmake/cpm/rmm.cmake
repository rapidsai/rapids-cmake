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
rapids_cpm_rmm
--------------

.. versionadded:: v21.10.00

Allow projects to find or build `RMM` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the current rapids-cmake version of RMM `as specified in the version file <cpm_versions>`
for  consistency across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_rmm( [BUILD_EXPORT_SET <export-name>]
                  [INSTALL_EXPORT_SET <export-name>]
                )

``BUILD_EXPORT_SET``
  Record that a :cmake:command:`CPMFindPackage(rmm)` call needs to occur as part of
  our build directory export set.

``INSTALL_EXPORT_SET``
  Record a :cmake:command:`find_dependency(rmm) <cmake:module:CMakeFindDependencyMacro>` call needs to occur as part of
  our install directory export set.

.. note::
  Installation of RMM will always occur when it is built as a subcomponent of the
  calling project.

Result Targets
^^^^^^^^^^^^^^
  rmm::rmm target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`rmm_SOURCE_DIR` is set to the path to the source directory of RMM.
  :cmake:variable:`rmm_BINAR_DIR`  is set to the path to the build directory of  RMM.
  :cmake:variable:`rmm_ADDED`      is set to a true value if RMM has not been added before.
  :cmake:variable:`rmm_VERSION`    is set to the version of RMM specified by the versions.json.

#]=======================================================================]
function(rapids_cpm_rmm)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rmm")

  set(to_install FALSE)
  if(INSTALL_EXPORT_SET IN_LIST ARGN)
    set(to_install TRUE)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(rmm version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  # Once we can require CMake 3.22 this can use `only_major_minor` for version searches
  rapids_cpm_find(rmm "${version}.0" ${ARGN}
                  GLOBAL_TARGETS rmm::rmm
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  EXCLUDE_FROM_ALL ${exclude}
                  OPTIONS "BUILD_TESTS OFF" "BUILD_BENCHMARKS OFF")

  # Propagate up variables that CPMFindPackage provide
  set(rmm_SOURCE_DIR "${rmm_SOURCE_DIR}" PARENT_SCOPE)
  set(rmm_BINARY_DIR "${rmm_BINARY_DIR}" PARENT_SCOPE)
  set(rmm_ADDED "${rmm_ADDED}" PARENT_SCOPE)
  set(rmm_VERSION ${version} PARENT_SCOPE)

  # rmm creates the correct namespace aliases
endfunction()
