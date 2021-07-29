#=============================================================================
# Copyright (c) 2020-2021, NVIDIA CORPORATION.
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
rapids_cpm_spdlog
-----------------

.. versionadded:: v21.10.00

Allow projects to find or build `spdlog` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses version 1.8.5 of spdlog for consistency across all RAPIDS projects

.. code-block:: cmake

  rapids_cpm_spdlog( [BUILD_EXPORT_SET <export-name>]
                     [INSTALL_EXPORT_SET <export-name>]
                   )

``BUILD_EXPORT_SET``
  Record that a :cmake:command:`CPMFindPackage(<PackageName> ...)` call needs to occur as part of
  our build directory export set.

``INSTALL_EXPORT_SET``
  Record a :cmake:command:`find_dependency(<PackageName> ...)` call needs to occur as part of
  our build directory export set.

.. note::
  Installation of spdlog will occur if an INSTALL_EXPORT_SET is provided, and spdlog
  is added to the project via :cmake:command:`add_subdirectory` by CPM.

Result Targets
^^^^^^^^^^^^^^
  spdlog::spdlog, spdlog::spdlog_header_only targets will be created

#]=======================================================================]
function(rapids_cpm_spdlog)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.spdlog")

  set(to_install OFF)
  if(INSTALL_EXPORT_SET IN_LIST ARGN)
    set(to_install ON)
  endif()

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(spdlog 1.8.5 ${ARGN}
                  CPM_ARGS
                  GIT_REPOSITORY https://github.com/gabime/spdlog.git
                  GIT_TAG v1.8.5
                  GIT_SHALLOW TRUE
                  OPTIONS "spdlog_INSTALL ${to_install}")

endfunction()
