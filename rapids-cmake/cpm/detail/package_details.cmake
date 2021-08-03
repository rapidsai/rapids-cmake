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
rapids_cpm_package_details
--------------------------

. code-block:: cmake

  rapids_cpm_package_details(<package_name> <version_variable> <git_url_variable> <git_tag_variable>)

#]=======================================================================]

function(rapids_cpm_package_details package_name version_var url_var tag_var)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rapids_cpm_package_details")

  include("${rapids-cmake-dir}/cpm/detail/load_preset_versions.cmake")
  rapids_cpm_load_preset_versions()

  get_property(json_data GLOBAL PROPERTY rapids_cpm_${package_name}_json)

  string(JSON version GET "${json_data}" version)
  string(JSON git_url GET "${json_data}" git_url)
  string(JSON git_tag GET "${json_data}" git_tag)

  # Evaluate any magic placeholders in the version or tag components
  include("${rapids-cmake-dir}/rapids-version.cmake") # json can use the `rapids-cmake-version` placeholder value
  cmake_language(EVAL CODE "set(version ${version})")
  cmake_language(EVAL CODE "set(git_tag ${git_tag})")

  set(${version_var} ${version} PARENT_SCOPE)
  set(${url_var} ${git_url} PARENT_SCOPE)
  set(${tag_var} ${git_tag} PARENT_SCOPE)

endfunction()
