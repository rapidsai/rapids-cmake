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

# Test URLs - using different files from reliable sources
set(test_url1 "https://raw.githubusercontent.com/rapidsai/rapids-cmake/main/README.md")
set(test_url2 "https://raw.githubusercontent.com/rapidsai/rapids-cmake/main/LICENSE")
set(output_file "${CMAKE_CURRENT_BINARY_DIR}/download_test/overwrite_test.txt")

# Test 1: Create initial file with first URL
rapids_download_with_retry("${test_url1}" "${output_file}")
if(NOT EXISTS "${output_file}")
  message(FATAL_ERROR "Initial download failed - file does not exist")
endif()

# Store initial file size
file(SIZE "${output_file}" initial_size)

# Test 2: Download different file to same location
rapids_download_with_retry("${test_url2}" "${output_file}")
if(NOT EXISTS "${output_file}")
  message(FATAL_ERROR "Overwrite download failed - file does not exist")
endif()

# Verify file was overwritten with new content
file(SIZE "${output_file}" new_size)
if(new_size EQUAL initial_size)
  message(FATAL_ERROR "File was not properly overwritten - sizes are identical")
endif()
