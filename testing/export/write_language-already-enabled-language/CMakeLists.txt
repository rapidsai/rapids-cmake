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
include(${rapids-cmake-dir}/export/write_language.cmake)

cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

# verify that enabling an already enabled langue install
# no hooks
project(write_language-already-enabled-language LANGUAGES CUDA)

add_subdirectory(A)

cmake_language(DEFER GET_CALL_IDS all_ids)
list(LENGTH all_ids list_len)
if(NOT list_len EQUAL 0)
  message(FATAL_ERROR "no rapids language hooks should be installed")
endif()

add_executable(write_language-already-enabled-language
               main.cu)
target_link_libraries(write_language-already-enabled-language PRIVATE A)
