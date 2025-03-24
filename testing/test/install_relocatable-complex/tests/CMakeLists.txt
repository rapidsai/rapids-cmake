#=============================================================================
# Copyright (c) 2023-2025, NVIDIA CORPORATION.
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

include(${rapids-cmake-dir}/rapids-test.cmake)

enable_testing()
rapids_test_init()

add_executable(verify_alloc ../main.cu)
target_include_directories(verify_alloc PRIVATE "${rapids-cmake-dir}/../docs/cpp_code_snippets/")

rapids_test_add(NAME verify_alloc COMMAND verify_alloc GPUS 1 INSTALL_COMPONENT_SET testing)
set_tests_properties(
    verify_alloc
    PROPERTIES
      ENVIRONMENT
      "STREAM_MODE=new_mode;LD_PRELOAD=$<TARGET_FILE:preload>"
      PASS_REGULAR_EXPRESSION "found a resource file"
  )
target_compile_features(verify_alloc PRIVATE cuda_std_17)

rapids_test_install_relocatable(INSTALL_COMPONENT_SET testing
                                DESTINATION bin/testing
                                INCLUDE_IN_ALL)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/verify_installed_CTestTestfile.cmake"
  "set(installed_test_file \"${CMAKE_CURRENT_BINARY_DIR}/install/bin/testing/CTestTestfile.cmake\")")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/verify_installed_CTestTestfile.cmake"
[==[

file(READ "${installed_test_file}" contents)

set(properties_match_strings [===[PROPERTIES ENVIRONMENT "STREAM_MODE]===]
                             [===[LD_PRELOAD=${CMAKE_INSTALL_PREFIX}/lib/libpreload.so.1.1.1]===])
foreach(to_match IN LISTS properties_match_strings)
  string(FIND "${contents}" ${to_match} is_found)
  if(is_found EQUAL -1)
    message(FATAL_ERROR "${contents}\nFailed to generate a proper set of test properties")
  endif()
endforeach()
]==])

add_custom_target(install_testing_component ALL
  COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}" --prefix install/ --config Debug
  COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_BINARY_DIR}/verify_installed_CTestTestfile.cmake"
  COMMAND ${CMAKE_CTEST_COMMAND} --test-dir install/bin/testing -C Debug --no-tests=error
  )

add_dependencies(install_testing_component preload generate_ctest_json verify_alloc)
