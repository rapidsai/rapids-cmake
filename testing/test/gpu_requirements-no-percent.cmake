#=============================================================================
# Copyright (c) 2022-2025, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/test/gpu_requirements.cmake)

add_test(fake_test COMMAND "${CMAKE_COMMAND} -E echo")

rapids_test_gpu_requirements(fake_test GPUS 9)

get_test_property(fake_test RESOURCE_GROUPS value)
if(NOT value STREQUAL "9,gpus:100")
  message(FATAL_ERROR "Unexpected RESOURCE_GROUPS test property value(${value}) after rapids_test_gpu_requirements"
  )
endif()
