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
rapids_cpm_nvcomp
-----------------

.. versionadded:: v22.06.00

Allow projects to find or build `nvComp` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of nvComp :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_nvcomp( [BUILD_EXPORT_SET <export-name>]
                     [INSTALL_EXPORT_SET <export-name>]
                     [USE_PROPRIETARY_BINARY <ON|OFF>]
                   )

``BUILD_EXPORT_SET``
  Record that a :cmake:command:`CPMFindPackage(<PackageName> ...)` call needs to occur as part of
  our build directory export set.

``INSTALL_EXPORT_SET``
  Record a :cmake:command:`find_dependency(<PackageName> ...) <cmake:module:CMakeFindDependencyMacro>` call needs to occur as part of
  our build directory export set.

.. note::
  Installation of nvcomp will occur if an INSTALL_EXPORT_SET is provided, and nvcomp
  is added to the project via :cmake:command:`add_subdirectory <cmake:command:add_subdirectory>` by CPM.

``USE_PROPRIETARY_BINARY``
  By enabling this flag you and using the software, you agree to fully comply with the terms and conditions of
  nvcomp's NVIDIA Software License Agreement. Found at https://developer.download.nvidia.com/compute/nvcomp/2.3/LICENSE.txt

Result Targets
^^^^^^^^^^^^^^
  nvcomp::nvcomp target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`nvcomp_SOURCE_DIR` is set to the path to the source directory of nvcomp.
  :cmake:variable:`nvcomp_BINARY_DIR` is set to the path to the build directory of  nvcomp.
  :cmake:variable:`nvcomp_ADDED`      is set to a true value if nvcomp has not been added before.
  :cmake:variable:`nvcomp_VERSION`    is set to the version of nvcomp specified by the versions.json.

#]=======================================================================]
function(rapids_cpm_nvcomp)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.nvcomp")

  set(options)
  set(one_value USE_PROPRIETARY_BINARY)
  set(multi_value)
  cmake_parse_arguments(RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(nvcomp version repository tag shallow exclude)

  # first see if we have a proprietary pre-built binary listed in versions.json and it if requested.
  #
  if(RAPIDS_USE_PROPRIETARY_BINARY)
    include("${rapids-cmake-dir}/cpm/detail/get_proprietary_binary.cmake")
    rapids_cpm_get_proprietary_binary(nvcomp ${version})
  endif()

  set(to_exclude OFF)
  if(NOT INSTALL_EXPORT_SET IN_LIST ARGN OR exclude)
    set(to_exclude ON)
  endif()

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(nvcomp ${version} ${ARGN}
                  GLOBAL_TARGETS nvcomp::nvcomp
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  EXCLUDE_FROM_ALL ${to_exclude})

  # Propagate up variables that CPMFindPackage provide
  set(nvcomp_SOURCE_DIR "${nvcomp_SOURCE_DIR}" PARENT_SCOPE)
  set(nvcomp_BINARY_DIR "${nvcomp_BINARY_DIR}" PARENT_SCOPE)
  set(nvcomp_ADDED "${nvcomp_ADDED}" PARENT_SCOPE)
  set(nvcomp_VERSION ${version} PARENT_SCOPE)

  # nvcomp creates the correct namespace aliases
endfunction()
