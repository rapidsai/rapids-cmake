#=============================================================================
# Copyright (c) 2024-2025, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/cmake/download_with_retry.cmake)

# Create a test directory
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/download_test")

# Test URL - using a small file from a reliable source
set(test_url "https://raw.githubusercontent.com/rapidsai/rapids-cmake/main/README.md")
set(output_file "${CMAKE_CURRENT_BINARY_DIR}/download_test/test_file.txt")

# Test 1: Basic download
rapids_download_with_retry("${test_url}" "${output_file}")
if(NOT EXISTS "${output_file}")
  message(FATAL_ERROR "Download failed - file does not exist")
endif()

# Verify file has content
file(SIZE "${output_file}" file_size)
if(file_size EQUAL 0)
  message(FATAL_ERROR "Downloaded file is empty")
endif()

# Test 2: Download with custom retry parameters
set(output_file2 "${CMAKE_CURRENT_BINARY_DIR}/download_test/test_file2.txt")
rapids_download_with_retry("${test_url}" "${output_file2}" MAX_RETRIES 2 RETRY_DELAY 1)
if(NOT EXISTS "${output_file2}")
  message(FATAL_ERROR "Download with custom parameters failed - file does not exist")
endif()

# Verify second file has content
file(SIZE "${output_file2}" file_size)
if(file_size EQUAL 0)
  message(FATAL_ERROR "Second downloaded file is empty")
endif()
