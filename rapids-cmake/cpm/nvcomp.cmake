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
  By enabling this flag and using the software, you agree to fully comply with the terms and conditions of
  nvcomp's NVIDIA Software License Agreement. Found at https://developer.download.nvidia.com/compute/nvcomp/2.3/LICENSE.txt

Result Targets
^^^^^^^^^^^^^^
  nvcomp::nvcomp target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`nvcomp_SOURCE_DIR` is set to the path to the source directory of nvcomp.
  :cmake:variable:`nvcomp_BINARY_DIR` is set to the path to the build directory of nvcomp.
  :cmake:variable:`nvcomp_ADDED`      is set to a true value if nvcomp has not been added before.
  :cmake:variable:`nvcomp_VERSION`    is set to the version of nvcomp specified by the versions.json.
  :cmake:variable:`nvcomp_proprietary_binary` is set to ON if the proprietary binary is being used

#]=======================================================================]
function(rapids_cpm_nvcomp)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.nvcomp")

  set(options)
  set(one_value USE_PROPRIETARY_BINARY BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  # Fix up RAPIDS_UNPARSED_ARGUMENTS to have EXPORT_SETS as this is need for rapids_cpm_find
  if(RAPIDS_INSTALL_EXPORT_SET)
    list(APPEND RAPIDS_UNPARSED_ARGUMENTS INSTALL_EXPORT_SET ${RAPIDS_INSTALL_EXPORT_SET})
  endif()
  if(RAPIDS_BUILD_EXPORT_SET)
    list(APPEND RAPIDS_UNPARSED_ARGUMENTS BUILD_EXPORT_SET ${RAPIDS_BUILD_EXPORT_SET})
  endif()

  set(to_exclude OFF)
  if(NOT RAPIDS_INSTALL_EXPORT_SET OR exclude)
    set(to_exclude ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(nvcomp version repository tag shallow exclude)

  # first see if we have a proprietary pre-built binary listed in versions.json and it if requested.
  set(nvcomp_proprietary_binary OFF) # will be set to true by rapids_cpm_get_proprietary_binary
  if(RAPIDS_USE_PROPRIETARY_BINARY)
    include("${rapids-cmake-dir}/cpm/detail/get_proprietary_binary.cmake")
    rapids_cpm_get_proprietary_binary(nvcomp ${version})
  endif()

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(nvcomp ${version} ${RAPIDS_UNPARSED_ARGUMENTS}
                  GLOBAL_TARGETS nvcomp::nvcomp
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  EXCLUDE_FROM_ALL ${to_exclude}
                  OPTIONS "BUILD_STATIC ON" "BUILD_TESTS OFF" "BUILD_BENCHMARKS OFF"
                          "BUILD_EXAMPLES OFF")

  # provice consistent targets between a found nvcomp
  # and one building from source
  if(NOT TARGET nvcomp::nvcomp AND TARGET nvcomp)
    add_library(nvcomp::nvcomp ALIAS nvcomp)
  endif()

  # Propagate up variables that CPMFindPackage provide
  set(nvcomp_SOURCE_DIR "${nvcomp_SOURCE_DIR}" PARENT_SCOPE)
  set(nvcomp_BINARY_DIR "${nvcomp_BINARY_DIR}" PARENT_SCOPE)
  set(nvcomp_ADDED "${nvcomp_ADDED}" PARENT_SCOPE)
  set(nvcomp_VERSION ${version} PARENT_SCOPE)
  set(nvcomp_proprietary_binary ${nvcomp_proprietary_binary} PARENT_SCOPE)

  # Setup up install rules when using the proprietary_binary When building from source, nvcomp will
  # set the correct install rules
  include("${rapids-cmake-dir}/export/find_package_root.cmake")
  if(RAPIDS_INSTALL_EXPORT_SET AND nvcomp_proprietary_binary)
    include(GNUInstallDirs)
    install(DIRECTORY "${nvcomp_ROOT}/lib/" DESTINATION ${CMAKE_INSTALL_LIBDIR})
    install(DIRECTORY "${nvcomp_ROOT}/include/" DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    # place the license information in the location that conda uses
    install(FILES "${nvcomp_ROOT}/NOTICE" DESTINATION info/licenses/ RENAME NVCOMP_NOTICE)
    install(FILES "${nvcomp_ROOT}/LICENSE" DESTINATION info/licenses/ RENAME NVCOMP_LICENSE)
  endif()

  if(RAPIDS_BUILD_EXPORT_SET AND nvcomp_proprietary_binary)
    # point our consumers to where they can find the pre-built version
    rapids_export_find_package_root(BUILD nvcomp "${nvcomp_ROOT}" ${RAPIDS_BUILD_EXPORT_SET})
  elseif(RAPIDS_BUILD_EXPORT_SET)
    # point our consumers to where they can find the source version
    rapids_export_find_package_root(BUILD nvcomp "${nvcomp_BINARY_DIR}" ${RAPIDS_BUILD_EXPORT_SET})
  endif()

endfunction()
