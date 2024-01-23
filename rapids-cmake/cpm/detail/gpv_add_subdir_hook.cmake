#=============================================================================
# Copyright (c) 2024, NVIDIA CORPORATION.
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

# Make sure we always have CMake 3.23 policies when executing this file Since we can be executing in
# directories of users of rapids-cmake which have a lower minimum cmake version and therefore
# different policies
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.23)

#[=======================================================================[.rst:
rapids_cpm_gpv_subdir_hook
--------------------------

.. versionadded:: v24.04.00

If we aren't in the root CMakeLists.txt of a project this function will ensure we add a hook to
our parent CMakeLists.txt and therefore recursively walk up the `add_subdirectory()` calls to the
parent.

For optimization purposes it will only install this hook if the parent hasn't setup the
hook. Either from a different subdir, or from directly calling `rapids_cpm_generate_pinned_versions`
#]=======================================================================]
function(rapids_cpm_gpv_add_subdir_hook)
  if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    return()
  endif()

  get_directory_property(parent_dir PARENT_DIRECTORY)
  cmake_language(DEFER DIRECTORY "${parent_dir}" GET_CALL_IDS rapids_existing_calls)
  if(NOT rapids_cpm_generate_pinned_versions IN_LIST rapids_existing_calls)
    cmake_language(DEFER DIRECTORY "${parent_dir}" ID rapids_cpm_generate_pinned_versions CALL
                   include "${rapids-cmake-dir}/cpm/detail/gpv_add_subdir_hook.cmake")
  endif()
endfunction()

rapids_cpm_gpv_add_subdir_hook()

include("${rapids-cmake-dir}/cpm/detail/gpv_write_file.cmake")
rapids_cpm_gpv_write_file()
cmake_policy(POP)
