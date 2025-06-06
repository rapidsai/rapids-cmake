#=============================================================================
# Copyright (c) 2022-2025, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake)

rapids_cpm_generate_patch_command(not_a_project 1 patch_command build_patch_only)
if(patch_command)
  message(FATAL_ERROR "not_a_project should not have a patch command")
endif()

rapids_cpm_init()
rapids_cpm_generate_patch_command(not_a_project 1 patch_command build_patch_only)
if(patch_command)
  message(FATAL_ERROR "not_a_project should not have a patch command")
endif()
