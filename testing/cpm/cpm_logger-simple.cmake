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
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/rapids_logger.cmake)

rapids_cpm_init()
if(TARGET rapids_logger::rapids_logger)
  message(FATAL_ERROR "Expected rapids_logger::rapids_logger not to exist")
endif()

if(COMMAND create_logger_macros)
  message(FATAL_ERROR "Expected create_logger_macros function not to exist")
endif()

rapids_cpm_rapids_logger()

if(NOT TARGET rapids_logger::rapids_logger)
  message(FATAL_ERROR "Expected rapids_logger::rapids_logger to exist")
endif()

if(NOT COMMAND create_logger_macros)
  message(FATAL_ERROR "Expected create_logger_macros function to exist")
endif()
