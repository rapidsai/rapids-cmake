#=============================================================================
# Copyright (c) 2022, NVIDIA CORPORATION.
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
rapids_cpm_cuco
---------------------

.. versionadded:: v22.08.00

Allow projects to find or build `cuCollections` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of cuCollections :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_cuco( [BUILD_EXPORT_SET <export-name>]
                   [INSTALL_EXPORT_SET <export-name>]
                   )

``BUILD_EXPORT_SET``
  Record that a :cmake:command:`CPMFindPackage(cuco)` call needs to occur as part of
  our build directory export set.

``INSTALL_EXPORT_SET``
  Record a :cmake:command:`find_dependency(cuco) <cmake:module:CMakeFindDependencyMacro>` call needs to occur as part of
  our install directory export set.

.. note::
  Installation of cuco will always occur when it is built as a subcomponent of the
  calling project.

Result Targets
^^^^^^^^^^^^^^
  cuco::cuco target will be created

#]=======================================================================]
function(rapids_cpm_cuco)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.cuco")

  set(options CPM_ARGS)
  set(one_value BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(CUCO "${options}" "${one_value}" "${multi_value}" ${ARGN})

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(libcudacxx version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(cuco ${version} ${CUCO_UNPARSED_ARGUMENTS}
                  GLOBAL_TARGETS cuco::cuco
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  # TODO: I'm not sure if we want to make this configurable. cudf currently sets
                  # this based on a separate variable, but raft does not, and doing so isn't
                  # consistent with other rapids-cmake cpm find commands. cudf later manually runs a
                  # rapids_export_package instead.
                  EXCLUDE_FROM_ALL ${exclude})

endfunction()
