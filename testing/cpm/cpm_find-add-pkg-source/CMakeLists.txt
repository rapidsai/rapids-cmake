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
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/find.cmake)

cmake_minimum_required(VERSION 3.30.4)
project(rapids-cpm-find-add-pkg-source LANGUAGES CXX)

set(CPM_ZLIB_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/mock_zlib_source_dir")

rapids_cpm_init()
rapids_cpm_find(ZLIB 1.0)

if(NOT TARGET MOCK_ZLIB)
  message(FATAL_ERROR "rapids_cpm_find failed to add ZLIB source dir ${CPM_ZLIB_SOURCE}")
endif()
