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
rapids_cpm_package_override
---------------------------

.. versionadded:: v21.10.00

Override `CPM` preset package information for the project.

.. code-block:: cmake

  rapids_cpm_package_override(<json_file_path>)

Allows projects to override the default values for any rapids-cmake
pre-configured cpm package.

The user provided json file must follow the `versions.json` format,
which is :ref:`documented here<cpm_version_format>`  and shown in the below
example:

.. literalinclude:: /packages/example.json
  :language: json

If the override file doesn't specify a value or package entry the default
version will be used.

#]=======================================================================]
function(rapids_cpm_package_override filepath)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rapids_cpm_package_override")

  file(READ "${filepath}" json_data)

  # Determine all the projects that exist in the json file
  string(JSON package_count LENGTH "${json_data}" packages)
  math(EXPR package_count "${package_count} - 1")

  # For each project cache the subset of the json for that project in a global property

  # cmake-lint: disable=E1120
  foreach(index RANGE ${package_count})
    string(JSON package_name MEMBER "${json_data}" packages ${index})
    string(JSON data GET "${json_data}" packages "${package_name}")
    set_property(GLOBAL PROPERTY rapids_cpm_${package_name}_override_json "${data}")
  endforeach()

endfunction()
