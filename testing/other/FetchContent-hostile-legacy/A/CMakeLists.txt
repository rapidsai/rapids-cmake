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

# verify no rapids-cmake variables have been specified
if(DEFINED rapids-cmake_SOURCE_DIR)
  message(FATAL_ERROR "")
endif()

include(FetchContent)
FetchContent_Declare(rapids-cmake GIT_REPOSITORY ${rapids-git-dir} GIT_TAG HEAD)
FetchContent_MakeAvailable(rapids-cmake)

if(NOT DEFINED rapids-cmake_SOURCE_DIR)
  message(FATAL_ERROR "expected variable rapids-cmake_SOURCE_DIR to exist")
endif()

if(NOT DEFINED rapids-cmake-dir)
  message(FATAL_ERROR "expected variable rapids-cmake-dir to exist")
endif()

if(NOT "${rapids-cmake-dir}" IN_LIST CMAKE_MODULE_PATH)
  message(FATAL_ERROR "expected variable rapids-cmake-dir to be inside CMAKE_MODULE_PATH")
endif()

if(NOT EXISTS "${rapids-cmake_SOURCE_DIR}/init.cmake")
  message(FATAL_ERROR "expected init.cmake to exist")
endif()

# Be hostile against rapids-cmake
set(CMAKE_MODULE_PATH "/not/a/directory")
