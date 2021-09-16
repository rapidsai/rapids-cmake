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
rapids_cpm_package_details
--------------------------

. code-block:: cmake

  rapids_cpm_package_details(<package_name> <version_variable> <git_url_variable> <git_tag_variable>)

#]=======================================================================]
function(rapids_cpm_package_details package_name version_var url_var tag_var shallow_var)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rapids_cpm_package_details")

  include("${rapids-cmake-dir}/cpm/detail/load_preset_versions.cmake")
  rapids_cpm_load_preset_versions()

  get_property(override_json_data GLOBAL PROPERTY rapids_cpm_${package_name}_override_json)
  get_property(json_data GLOBAL PROPERTY rapids_cpm_${package_name}_json)

  # Parse required fields
  function(rapids_cpm_json_get_value name)
    string(JSON value ERROR_VARIABLE have_error GET "${override_json_data}" ${name})
    if(have_error)
      string(JSON value ERROR_VARIABLE have_error GET "${json_data}" ${name})
    endif()

    if(NOT have_error)
      set(${name} ${value} PARENT_SCOPE)
    endif()
  endfunction()

  rapids_cpm_json_get_value(version)
  rapids_cpm_json_get_value(git_url)
  rapids_cpm_json_get_value(git_tag)

  # Parse optional fields, set the variable to the 'default' value first
  set(git_shallow ON)
  rapids_cpm_json_get_value(git_shallow)

  # Evaluate any magic placeholders in the version or tag components including the
  # `rapids-cmake-version` value
  if(NOT DEFINED rapids-cmake-version)
    include("${rapids-cmake-dir}/rapids-version.cmake")
  endif()

  cmake_language(EVAL CODE "set(version ${version})")
  cmake_language(EVAL CODE "set(git_tag ${git_tag})")

  set(${version_var} ${version} PARENT_SCOPE)
  set(${url_var} ${git_url} PARENT_SCOPE)
  set(${tag_var} ${git_tag} PARENT_SCOPE)
  set(${shallow_var} ${git_shallow} PARENT_SCOPE)

endfunction()
