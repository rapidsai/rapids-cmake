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

file(GLOB _install_component1_files ${CMAKE_CURRENT_BINARY_DIR}/install-component1/*.so)
file(GLOB _install_component2_files ${CMAKE_CURRENT_BINARY_DIR}/install-component2/*.so)

if(NOT _install_component1_files MATCHES "test1")
  message(FATAL_ERROR "test1 was not installed into install-component1")
endif()
if(_install_component1_files MATCHES "test2")
  message(FATAL_ERROR "test2 was installed into install-component1")
endif()
if(_install_component2_files MATCHES "test1")
  message(FATAL_ERROR "test1 was installed into install-component2")
endif()
if(NOT _install_component2_files MATCHES "test2")
  message(FATAL_ERROR "test2 was not installed into install-component2")
endif()
