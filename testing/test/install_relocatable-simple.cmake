#=============================================================================
# Copyright (c) 2022-2023, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/test/init.cmake)
include(${rapids-cmake-dir}/test/add.cmake)
include(${rapids-cmake-dir}/test/install_relocatable.cmake)

enable_language(CUDA)
rapids_test_init()

rapids_test_add(NAME verify_ COMMAND ls GPUS 1 INSTALL_COMPONENT_SET testing)

rapids_test_install_relocatable(INSTALL_COMPONENT_SET testing
                                DESTINATION bin/testing
                                EXCLUDE_FROM_ALL)

set(generated_testfile "${CMAKE_CURRENT_BINARY_DIR}/rapids-cmake/testing/CTestTestfile.cmake.to_install")
file(READ "${generated_testfile}" contents)


set(add_test_match_strings [===[add_test([=[verify_]=] cmake;-Dcommand_to_run=ls;-Dcommand_args=;-P;./run_gpu_test.cmake)]===])
foreach(item IN LISTS add_test_match_strings)
  string(FIND "${contents}" ${item} is_found)
  if(is_found EQUAL -1)
    message(FATAL_ERROR "Failed to generate an installed `add_test` for verify_")
  endif()
endforeach()

set(properties_match_string [===[PROPERTIES RESOURCE_GROUPS 1,gpus:100]===])
string(FIND "${contents}" ${properties_match_string} is_found)
if(is_found EQUAL -1)
  message(FATAL_ERROR "Failed to generate an installed `GPU` requirements for verify_")
endif()
