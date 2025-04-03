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

rapids_cpm_nvtx3(INSTALL_EXPORT_SET uses-nvtx3-exports)

add_library(uses-nvtx3-cpp INTERFACE)
target_link_libraries(uses-nvtx3-cpp INTERFACE nvtx3::nvtx3-cpp)
install(TARGETS uses-nvtx3-cpp EXPORT uses-nvtx3-exports)

rapids_export(
  INSTALL uses-nvtx3
  EXPORT_SET uses-nvtx3-exports
  GLOBAL_TARGETS uses-nvtx3-cpp
  NAMESPACE uses-nvtx3::
)
