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
rapids_cpm_gtest
----------------

.. versionadded:: v21.10.00

Allow projects to find or build `Google Test` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of GTest :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_gtest( [BUILD_EXPORT_SET <export-name>]
                    [INSTALL_EXPORT_SET <export-name>]
                  )
.. note::
  Installation of GTest will occur if an INSTALL_EXPORT_SET is provided, and GTest
  is added to the project via :cmake:command:`add_subdirectory` by CPM.

Result Targets
^^^^^^^^^^^^^^
  GTest::gtest, GTest::gmock, GTest::gtest_main, GTest::gmock_main targets will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`GTest_SOURCE_DIR` is set to the path to the source directory of GTest.
  :cmake:variable:`GTest_BINAR_DIR`  is set to the path to the build directory of  GTest.
  :cmake:variable:`GTest_ADDED`      is set to a true value if GTest has not been added before.
  :cmake:variable:`GTest_VERSION`    is set to the version of GTest specified by the versions.json.

#]=======================================================================]
function(rapids_cpm_gtest)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.gtest")

  set(to_install OFF)
  if(INSTALL_EXPORT_SET IN_LIST ARGN)
    set(to_install ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(GTest version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(GTest ${version} ${ARGN}
                  GLOBAL_TARGETS GTest::gtest GTest::gmock GTest::gtest_main GTest::gmock_main
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  EXCLUDE_FROM_ALL ${exclude}
                  OPTIONS "INSTALL_GTEST ${to_install}")

  # Propagate up variables that CPMFindPackage provide
  set(GTest_SOURCE_DIR "${GTest_SOURCE_DIR}" PARENT_SCOPE)
  set(GTest_BINARY_DIR "${GTest_BINARY_DIR}" PARENT_SCOPE)
  set(GTest_ADDED "${GTest_ADDED}" PARENT_SCOPE)
  set(GTest_VERSION ${version} PARENT_SCOPE)

  if(NOT TARGET GTest::gtest AND TARGET gtest)
    add_library(GTest::gtest ALIAS gtest)
    add_library(GTest::gmock ALIAS gmock)
    add_library(GTest::gtest_main ALIAS gtest_main)
    add_library(GTest::gmock_main ALIAS gmock_main)
  endif()
endfunction()
