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
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/find.cmake)

cmake_minimum_required(VERSION 3.20)
project(rapids-test-project LANGUAGES CXX)


function(generate_fake_build_dir_with_config name version config_file version_file)
  include(CMakePackageConfigHelpers)

  # Generate a fake config module for RapidsTestFind
  set(build_dir "${CMAKE_CURRENT_BINARY_DIR}/${name}-build/")
  file(MAKE_DIRECTORY ${build_dir})

  configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/${config_file}"
    "${build_dir}/${config_file}"
    INSTALL_DESTINATION "${build_dir}/${config_file}"
  )

  write_basic_package_version_file("${build_dir}/${version_file}"
    VERSION ${version}
    COMPATIBILITY SameMajorVersion)
endfunction()

generate_fake_build_dir_with_config(RapidsTestFind 0.1
    RapidsTestFindConfig.cmake
    RapidsTestFindConfigVersion.cmake)

generate_fake_build_dir_with_config(RapidsTestFind2 0.2
    rapidstestfind2-config.cmake
    rapidstestfind2-config-version.cmake)

rapids_cpm_init()
set(FETCHCONTENT_BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(CPM_LOCAL_PACKAGES_ONLY ON)
rapids_cpm_find(RapidsTestFind 0.1.0)
rapids_cpm_find(RapidsTestFind2 0.2.0)

if(NOT TARGET RapidsTest::RapidsTest)
  message(FATAL_ERROR "RapidsTest targets should be generated")
endif()
if(NOT TARGET RapidsTest2::RapidsTest)
  message(FATAL_ERROR "RapidsTest2 targets should be generated")
endif()
