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

# Make sure last item doesn't have "-real"
list(POP_BACK CMAKE_CUDA_ARCHITECTURES last_value)
string(FIND ${last_value} "-real" location)
if(NOT location EQUAL -1)
  message(FATAL_ERROR "CMAKE_CUDA_ARCHITECTURES last value shouldn't have `-real`")
endif()

# Each item should be `number-real` and should be ordered from low to high. In addition the values
# should map to Volta+ GPU arch ( 70+ )
set(previous_value 69)
foreach(value IN LISTS CMAKE_CUDA_ARCHITECTURES)
  # verify it ends with `-real`
  string(FIND ${value} "-real" location)
  if(location LESS "0")
    message(FATAL_ERROR "All values but the last in CMAKE_CUDA_ARCHITECTURES should have `-real`")
  endif()

  string(REPLACE "-real" "" value "${value}")
  if(value LESS previous_value)
    message(FATAL_ERROR "CMAKE_CUDA_ARCHITECTURES values should be ordered lowest to highest."
                        "with lowest >= 70")
  endif()
endforeach()

if(last_value LESS previous_value)
  message(FATAL_ERROR "CMAKE_CUDA_ARCHITECTURES values should be ordered lowest to highest."
                      "with lowest >= 70")
endif()

list(APPEND CMAKE_CUDA_ARCHITECTURES ${last_value})

if(NOT DEFINED CACHE{CMAKE_CUDA_ARCHITECTURES})
  message(FATAL_ERROR "rapids_cuda_set_architectures didn't make CMAKE_CUDA_ARCHITECTURES a cache variable"
  )
endif()

if(CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL 12.8.0)
  if(NOT CMAKE_CUDA_FLAGS MATCHES "Wno-deprecated-gpu-targets")
    message(FATAL_ERROR "CMAKE_CUDA_FLAGS should have -Wno-deprecated-gpu-targets")
  endif()
endif()
