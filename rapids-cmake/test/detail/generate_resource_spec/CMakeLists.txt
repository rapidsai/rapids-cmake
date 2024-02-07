#=============================================================================
# Copyright (c) 2024, NVIDIA CORPORATION.
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
cmake_minimum_required(VERSION 3.23.1)
project(generate_resource_spec CXX)

find_package(CUDAToolkit QUIET)
find_package(Threads REQUIRED)

add_executable(generate_ctest_json generate_resource_spec.cpp)
target_link_libraries(generate_ctest_json PRIVATE Threads::Threads rt ${CMAKE_DL_LIBS})
if(CUDAToolkit_FOUND)
  target_link_libraries(generate_ctest_json PRIVATE CUDA::cudart)
  target_compile_definitions(generate_ctest_json PRIVATE HAVE_CUDA)
endif()

add_custom_command(TARGET generate_ctest_json POST_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:generate_ctest_json>
                           "${output_file}" COMMENT "Copying executable to destination")
