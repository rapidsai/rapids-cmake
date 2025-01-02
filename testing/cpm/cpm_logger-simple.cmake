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

function(check_target target)
  if(NOT TARGET "${target}")
    message(FATAL_ERROR "Target ${target} was not created.")
  endif()
endfunction()

function(check_file fn)
  if(NOT EXISTS "${fn}")
    message(FATAL_ERROR "File ${fn} was not created.")
  endif()
endfunction()

check_target("${logger_target}")
check_target("${logger_impl_target}")
check_target("${logger_namespace}::${logger_target}")
check_target("${logger_namespace}::${logger_impl_target}")

set(base_dir "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${logger_namespace}")
check_file("${base_dir}/logger.hpp")
check_file("${base_dir}/logger_impl/logger_impl.hpp")
check_file("${base_dir}/logger_impl/logger.cpp")

