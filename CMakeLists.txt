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
#
# This is an entry point for other projects using rapids-cmake
# Nothing should happen except setup to allow usage of the core components
#

# Enfore the minimum required CMake version for all users
cmake_minimum_required(VERSION 3.20.1 FATAL_ERROR)

# Hoist up this directory as a search path for CMake module
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/rapids-cmake")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

set(rapids-cmake-dir "${CMAKE_CURRENT_LIST_DIR}/rapids-cmake" PARENT_SCOPE)
