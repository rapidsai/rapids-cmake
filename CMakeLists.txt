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
# This is an entry point for the vast majorty of projects using rapids-cmake.
#
# Unlike `init.cmake` this will setup the following cache variables:
# - CMAKE_MODULE_PATH
# - rapids-cmake-dir
#
# This is done to make sure that rapids-cmake can be properly included
# multiple times by sibling projects without issue
#

# Enfore the minimum required CMake version for all users
cmake_minimum_required(VERSION 3.20.1 FATAL_ERROR)

if(NOT "${CMAKE_CURRENT_LIST_DIR}/rapids-cmake" IN_LIST CMAKE_MODULE_PATH)
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/rapids-cmake")
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" CACHE PATH "" FORCE)
  mark_as_advanced(CMAKE_MODULE_PATH)

  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
endif()

if(NOT DEFINED CACHE{rapids-cmake-dir})
  set(rapids-cmake-dir "${CMAKE_CURRENT_LIST_DIR}/rapids-cmake" CACHE PATH "" FORCE)
  mark_as_advanced(rapids-cmake-dir)

  set(rapids-cmake-dir "${rapids-cmake-dir}" PARENT_SCOPE)
endif()
