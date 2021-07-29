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
rapids_cpm_nvbench
------------------

.. versionadded:: v21.10.00

Allow projects to find or build `nvbench` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses latest version of nvbench for consistency across all RAPIDS projects

.. code-block:: cmake

  rapids_cpm_nvbench( [BUILD_EXPORT_SET <export-name>] )

``BUILD_EXPORT_SET``
  Record that a :cmake:command:`CPMFindPackage(nvbench)` call needs to occur as part of
  our build directory export set.

.. note::

  RAPIDS-cmake will error out if an INSTALL_EXPORT_SET is provided, as nvbench
  doesn't provide any support for installation.

Result Targets
^^^^^^^^^^^^^^
  nvbench::nvbench target will be created

  nvbench::main target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`nvbench_SOURCE_DIR` is set to the path to the source directory of nvbench.
  :cmake:variable:`nvbench_BINAR_DIR`  is set to the path to the build directory of  nvbench.
  :cmake:variable:`nvbench_ADDED`      is set to a true value if nvbench has not been added before.

#]=======================================================================]
function(rapids_cpm_nvbench)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.nvbench")

  set(to_install FALSE)
  if(INSTALL_EXPORT_SET IN_LIST ARGN)
    message(FATAL_ERROR "nvbench doesn't provide install rules.
            It can't be part of an INSTALL_EXPORT_SET")
  endif()

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(nvbench 0.0 ${ARGN}
                  GLOBAL_TARGETS nvbench::nvbench nvbench::main
                  CPM_ARGS
                  GIT_REPOSITORY https://github.com/NVIDIA/nvbench.git
                  GIT_TAG main
                  GIT_SHALLOW TRUE
                  OPTIONS "NVBench_ENABLE_EXAMPLES OFF" "NVBench_ENABLE_TESTING OFF")

  # Propagate up variables that CPMFindPackage provide
  set(nvbench_SOURCE_DIR "${nvbench_SOURCE_DIR}" PARENT_SCOPE)
  set(nvbench_BINARY_DIR "${nvbench_BINARY_DIR}" PARENT_SCOPE)
  set(nvbench_ADDED "${nvbench_ADDED}" PARENT_SCOPE)

  # nvbench creates the correct namespace aliases
endfunction()
