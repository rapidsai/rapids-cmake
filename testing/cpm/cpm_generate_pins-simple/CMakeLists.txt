#=============================================================================
# Copyright (c) 2024-2025, NVIDIA CORPORATION.
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
cmake_minimum_required(VERSION 3.30.4)
project(rapids-test-project LANGUAGES CXX)

include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/fmt.cmake)
include(${rapids-cmake-dir}/cpm/nvtx3.cmake)
include(${rapids-cmake-dir}/cpm/rmm.cmake)

rapids_cpm_init(GENERATE_PINNED_VERSIONS)
rapids_cpm_fmt(DOWNLOAD_ONLY ON)
rapids_cpm_nvtx3(DOWNLOAD_ONLY ON)
rapids_cpm_rmm(DOWNLOAD_ONLY ON)

# only check projects that were downloaded by CPM (ignore those already in the build environment)
foreach(proj IN ITEMS fmt nvtx3 rmm)
  if(${proj}_SOURCE_DIR)
    list(APPEND projects-to-verify ${proj})
  endif()
endforeach()

include("${rapids-cmake-testing-dir}/cpm/verify_generated_pins.cmake")
verify_generated_pins(verify_pins PROJECTS ${projects-to-verify})
