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

set(name_suffix b s r)
set(modes balanced size runtime_perf)
set(compile_options balance size speed)

foreach(suffix mode IN ZIP_LISTS name_suffix modes)
  rapids_cuda_enable_fatbin_compression(VARIABLE not_yet_${suffix} TUNE_FOR ${mode})

  set(exists_${suffix} "-extra-flag")
  rapids_cuda_enable_fatbin_compression(VARIABLE exists_${suffix} TUNE_FOR ${mode})
endforeach()

# Validate all the targets now have the proper values
foreach(suffix mode option IN ZIP_LISTS name_suffix modes compile_options)

  foreach(var IN ITEMS not_yet_${suffix} exists_${suffix})
    if(NOT ${var} MATCHES "-Xfatbin=-compress-all")
      message(FATAL_ERROR "${var} missing the compress-all compile flag")
    endif()
    if(NOT ${var} MATCHES "--compress-mode=${option}")
      message(FATAL_ERROR "${var} missing the proper compress-mode flag of ${option} instead has ${compile_opts}"
      )
    endif()
  endforeach()

  if(NOT exists_${suffix} MATCHES "-extra-flag")
    message(FATAL_ERROR "rapids_cuda_enable_fatbin_compression cleared existing values in a variable"
    )
  endif()

endforeach()

# Handle checking all the tune types that map to `rapids`
set(exists "-extra-flag")
set(exists_rapids "-extra-flag")

foreach(var IN ITEMS not_yet exists)
  rapids_cuda_enable_fatbin_compression(VARIABLE ${var})
  rapids_cuda_enable_fatbin_compression(VARIABLE ${var}_rapids TUNE_FOR rapids)

  if(NOT ${var} STREQUAL ${var}_rapids)
    message(FATAL_ERROR "rapids_cuda_enable_fatbin_compression without any TUNE_FOR should match 'rapids'"
    )
  endif()
  if(NOT ${var} MATCHES "-Xfatbin=-compress-all")
    message(FATAL_ERROR "${var} missing the compress-all compile flag")
  endif()
  if(CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL 13.0.0 AND NOT ${var} MATCHES
                                                                  "--compress-mode")
    message(FATAL_ERROR "${var} missing the compress-mode compile flag")
  endif()
endforeach()

if(NOT exists MATCHES "-extra-flag")
  message(FATAL_ERROR "rapids_cuda_enable_fatbin_compression cleared existing values in a variable")
endif()
