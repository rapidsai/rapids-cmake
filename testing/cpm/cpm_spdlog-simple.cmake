#=============================================================================
# Copyright (c) 2021, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/cpm/spdlog.cmake)

rapids_cpm_init()

if(TARGET spdlog::spdlog_header_only)
  message(FATAL_ERROR "Expected spdlog::spdlog_header_only not to exist")
endif()

rapids_cpm_spdlog()
if(NOT TARGET spdlog::spdlog_header_only)
  message(FATAL_ERROR "Expected spdlog::spdlog_header_only target to exist")
endif()

rapids_cpm_spdlog()
