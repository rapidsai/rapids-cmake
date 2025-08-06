#=============================================================================
# Copyright (c) 2025, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/cuda/enable_fatbin_compression.cmake)

enable_language(CUDA)

set(stub_file "${CMAKE_CURRENT_BINARY_DIR}/stub.cu")
file(WRITE "${stub_file}" [=[int stub(){return 42;}]=])

set(name_suffix b s r)
set(modes balanced size runtime_perf)
set(compile_options balance size speed)

foreach(suffix mode IN ZIP_LISTS name_suffix modes)
  rapids_cuda_enable_fatbin_compression(TARGET not_yet_${suffix} TUNE_FOR ${mode})

  add_library(exists_${suffix} SHARED ${stub_file})
  rapids_cuda_enable_fatbin_compression(TARGET exists_${suffix} TUNE_FOR ${mode})
endforeach()

# Validate all the targets now have the proper values
foreach(suffix mode option IN ZIP_LISTS name_suffix modes compile_options)
  foreach(target IN ITEMS not_yet_${suffix} exists_${suffix})
    get_target_property(compile_opts ${target} INTERFACE_COMPILE_OPTIONS)
    if(NOT compile_opts MATCHES "-Xfatbin=-compress-all")
      message(FATAL_ERROR "${target} missing the compress-all compile flag")
    endif()
    if(NOT compile_opts MATCHES "--compress-mode=${option}")
      message(FATAL_ERROR "${target} missing the proper compress-mode flag of ${option} instead has ${compile_opts}"
      )
    endif()
  endforeach()
endforeach()

# Handle checking all the tune types that map to `rapids`
add_library(exists SHARED ${stub_file})
add_library(exists_rapids SHARED ${stub_file})

foreach(target IN ITEMS not_yet exists)
  rapids_cuda_enable_fatbin_compression(TARGET ${target})
  rapids_cuda_enable_fatbin_compression(TARGET ${target}_rapids TUNE_FOR rapids)

  get_target_property(compile_opts_a ${target} INTERFACE_COMPILE_OPTIONS)
  get_target_property(compile_opts_b ${target}_rapids INTERFACE_COMPILE_OPTIONS)
  if(NOT compile_opts_a STREQUAL compile_opts_b)
    message(FATAL_ERROR "rapids_cuda_enable_fatbin_compression without any TUNE_FOR should match 'rapids'"
    )
  endif()
  if(NOT compile_opts_a MATCHES "-Xfatbin=-compress-all")
    message(FATAL_ERROR "${target} missing the compress-all compile flag")
  endif()
  if(CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL 13.0.0 AND NOT compile_opts_a MATCHES
                                                                  "--compress-mode")
    message(FATAL_ERROR "${target} missing the compress-mode compile flag")
  endif()
endforeach()
