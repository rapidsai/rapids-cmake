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
# This is an entry point for other projects using rapids-cmake that
# don't want any cache variables constructed
#
# Nothing should happen except setup to allow usage of the core components
#

# Hoist up this directory as a search path for CMake module
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/rapids-cmake")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")

set(rapids-cmake-dir "${CMAKE_CURRENT_LIST_DIR}/rapids-cmake")
