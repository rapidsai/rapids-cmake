#=============================================================================
# Copyright (c) 2018-2021, NVIDIA CORPORATION.
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
rapids_cpm_init
---------------

.. versionadded:: v21.06.00

Establish the `CPM` and preset package infrastructure for the project.

.. code-block:: cmake

  rapids_cpm_init()

The CPM module will be downloaded based on the state of :cmake:variable:`CPM_SOURCE_CACHE` and
:cmake:variable:`ENV{CPM_SOURCE_CACHE}`. This allows multiple nested projects to share the
same download of CPM. If those variables aren't set the file will be cached
in the build tree of the calling project

.. note::
  Must be called before any invocation of :cmake:command:`rapids_cpm_find`.

#]=======================================================================]
function(rapids_cpm_init)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.init")

  include("${rapids-cmake-dir}/cpm/detail/load_preset_versions.cmake")
  rapids_cpm_load_preset_versions()

  include("${rapids-cmake-dir}/cpm/detail/download.cmake")
  rapids_cpm_download()

endfunction()
