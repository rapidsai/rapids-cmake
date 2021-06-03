#=============================================================================
# Copyright (c) 2018-2021, NVIDIA CORPORATION.
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

add_cmake_config_test( rapids-cmake.cmake )

add_cmake_config_test( build_type-debug.cmake )
add_cmake_config_test( build_type-multiple.cmake )
add_cmake_config_test( build_type-user-specified.cmake)

add_cmake_config_test( conda_env-build.cmake )
add_cmake_config_test( conda_env-invalid.cmake )
add_cmake_config_test( conda_env-prefix.cmake )

add_cmake_config_test( make_global-already-imported-global.cmake )
add_cmake_config_test( make_global-is-alias.cmake )
add_cmake_config_test( make_global-no-targets.cmake )
add_cmake_config_test( make_global-not-imported.cmake )
add_cmake_config_test( make_global-valid.cmake )

add_cmake_config_test( parse_version-major-valid.cmake )
add_cmake_config_test( parse_version-major-invalid.cmake )
add_cmake_config_test( parse_version-minor-invalid.cmake )
add_cmake_config_test( parse_version-minor-valid.cmake )
add_cmake_config_test( parse_version-patch-valid.cmake )
add_cmake_config_test( parse_version-patch-invalid.cmake )
add_cmake_config_test( parse_version-major_minor-invalid.cmake )
add_cmake_config_test( parse_version-major_minor-valid.cmake )

add_cmake_build_test( write_version-absolute )
add_cmake_build_test( write_version-relative )
