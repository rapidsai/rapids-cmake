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

  if(NOT not_yet_${suffix} MATCHES "-Xfatbin=-compress-all")
    message(FATAL_ERROR "not_yet_${suffix} missing the compress-all compile flag")
  endif()
  if(NOT not_yet_${suffix} MATCHES "--compress-mode=${option}")
    message(FATAL_ERROR "not_yet_${suffix} missing the proper compress-mode flag of ${option} instead has ${compile_opts}"
    )
  endif()

  if(NOT exists_${suffix} MATCHES "-extra-flag")
    message(FATAL_ERROR "rapids_cuda_enable_fatbin_compression cleared existing values in a variable"
    )
  endif()
  if(NOT exists_${suffix} MATCHES "-Xfatbin=-compress-all")
    message(FATAL_ERROR "exists_${suffix} missing the compress-all compile flag")
  endif()
  if(NOT exists_${suffix} MATCHES "--compress-mode=${option}")
    message(FATAL_ERROR "exists_${suffix} missing the proper compress-mode flag of ${option} instead has ${compile_opts}"
    )
  endif()

endforeach()

# Handle checking all the tune types that map to `rapids`
rapids_cuda_enable_fatbin_compression(VARIABLE not_yet)
rapids_cuda_enable_fatbin_compression(VARIABLE not_yet_rapids TUNE_FOR rapids)

if(NOT not_yet STREQUAL not_yet_rapids)
  message(FATAL_ERROR "rapids_cuda_enable_fatbin_compression without any TUNE_FOR should match 'rapids'"
  )
endif()
if(NOT not_yet MATCHES "-Xfatbin=-compress-all")
  message(FATAL_ERROR "not_yet missing the compress-all compile flag")
endif()
if(CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL 13.0.0 AND NOT not_yet MATCHES
                                                                "--compress-mode")
  message(FATAL_ERROR "not_yet missing the compress-mode compile flag")
endif()

set(exists "-extra-flag")
set(exists_rapids "-extra-flag")
rapids_cuda_enable_fatbin_compression(VARIABLE exists)
rapids_cuda_enable_fatbin_compression(VARIABLE exists_rapids TUNE_FOR rapids)

if(NOT exists STREQUAL exists_rapids)
  message(FATAL_ERROR "rapids_cuda_enable_fatbin_compression without any TUNE_FOR should match 'rapids'"
  )
endif()
if(NOT exists MATCHES "-extra-flag")
  message(FATAL_ERROR "rapids_cuda_enable_fatbin_compression cleared existing values in a variable")
endif()
if(NOT exists MATCHES "-Xfatbin=-compress-all")
  message(FATAL_ERROR "not_yet missing the compress-all compile flag")
endif()
if(CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL 13.0.0 AND NOT exists MATCHES
                                                                "--compress-mode")
  message(FATAL_ERROR "not_yet missing the compress-mode compile flag")
endif()
