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
rapids_cpm_gbench
-----------------

.. versionadded:: v22.12.00

Allow projects to find or build `Google Benchmark` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of GBench :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_gbench( [BUILD_EXPORT_SET <export-name>]
                     [INSTALL_EXPORT_SET <export-name>]
                     [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: GBench
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  benchmark::benchmark targets will be created

#]=======================================================================]
function(rapids_cpm_gbench)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.gbench")

  set(to_install OFF)
  if(INSTALL_EXPORT_SET IN_LIST ARGN)
    set(to_install ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(GBench version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(GBench ${version} patch_command)

  include("${rapids-cmake-dir}/cmake/install_lib_dir.cmake")
  rapids_cmake_install_lib_dir(lib_dir)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(GBench ${version} ${ARGN}
                  GLOBAL_TARGETS benchmark::benchmark benchmark::benchmark_main
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  PATCH_COMMAND ${patch_command}
                  EXCLUDE_FROM_ALL ${exclude}
                  OPTIONS "BENCHMARK_ENABLE_GTEST_TESTS OFF" "BENCHMARK_ENABLE_TESTING OFF"
                          "BENCHMARK_ENABLE_INSTALL ${to_install}"
                          "CMAKE_INSTALL_LIBDIR ${lib_dir}")

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(GBench)

  if(NOT TARGET benchmark::benchmark AND TARGET benchmark)
    add_library(benchmark::benchmark ALIAS benchmark)
  endif()
endfunction()
