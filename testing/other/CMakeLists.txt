#=============================================================================
# Copyright (c) 2021-2025, NVIDIA CORPORATION.
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
add_cmake_config_test(rapids_cmake-multiple-cpm NO_RAPIDS_CMAKE_HOOKS)
add_cmake_config_test(rapids_cmake-multiple-simple NO_RAPIDS_CMAKE_HOOKS)

add_cmake_config_test(rapids_cmake-fetch-via-git NO_RAPIDS_CMAKE_HOOKS)
add_cmake_config_test(rapids_cmake-fetch-via-zip NO_RAPIDS_CMAKE_HOOKS)

add_cmake_config_test(FetchContent-legacy NO_RAPIDS_CMAKE_HOOKS)
add_cmake_config_test(FetchContent-hostile-legacy NO_RAPIDS_CMAKE_HOOKS)
