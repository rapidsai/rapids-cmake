#=============================================================================
# Copyright (c) 2022, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/logger.cmake)

rapids_cpm_init()
rapids_cpm_logger()

set(logger_namespace rapids)
set(logger_target "${logger_namespace}_logger")
set(logger_impl_target "${logger_namespace}_logger_impl")
rapids_make_logger("${logger_namespace}")


if(NOT TARGET "${logger_target}")
  message(FATAL_ERROR "Logger target was not created.")
endif()
if(NOT TARGET "${logger_impl_target}")
  message(FATAL_ERROR "Logger impl target was not created.")
endif()
if(NOT TARGET "${logger_namespace}::${logger_target}")
  message(FATAL_ERROR "Alias logger target was not created.")
endif()
if(NOT TARGET "${logger_namespace}::${logger_impl_target}")
  message(FATAL_ERROR "Alias logger impl target was not created.")
endif()

if(NOT EXISTS "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${logger_namespace}/logger.hpp")
  message(FATAL_ERROR "Logger header not generated")
endif()
if(NOT EXISTS "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${logger_namespace}/logger_impl/logger_impl.hpp")
  message(FATAL_ERROR "Logger implementation header not generated")
endif()
if(NOT EXISTS "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${logger_namespace}/logger_impl/logger.cpp")
  message(FATAL_ERROR "Logger implementation source file not generated")
endif()

