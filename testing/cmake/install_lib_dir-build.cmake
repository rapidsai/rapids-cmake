#=============================================================================
# Copyright (c) 2021-2025, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/cmake/install_lib_dir.cmake)

set(ENV{CONDA_BUILD} "1")
set(ENV{PREFIX} "/opt/conda/prefix")
set(CMAKE_INSTALL_PREFIX "/opt/conda/prefix")

rapids_cmake_install_lib_dir(lib_dir)

if(NOT lib_dir STREQUAL "lib")
  message(FATAL_ERROR "rapids_cmake_install_lib_dir computed '${lib_dir}', but we expected 'lib' as we are in a CONDA env"
  )
endif()

# verify CMAKE_INSTALL_LIBDIR doesn't exist
if(DEFINED CMAKE_INSTALL_LIBDIR)
  message(FATAL_ERROR "rapids_cmake_install_lib_dir shouldn't have caused the CMAKE_INSTALL_LIBDIR variable to exist"
  )
endif()

rapids_cmake_install_lib_dir(lib_dir MODIFY_INSTALL_LIBDIR)

if(NOT lib_dir STREQUAL "lib")
  message(FATAL_ERROR "rapids_cmake_install_lib_dir computed '${lib_dir}', but we expected 'lib' as we are in a CONDA env"
  )
endif()
if(NOT CMAKE_INSTALL_LIBDIR STREQUAL "lib")
  message(FATAL_ERROR "CMAKE_INSTALL_LIBDIR computed to '${CMAKE_INSTALL_LIBDIR}', but we expected 'lib' as we are in a CONDA env"
  )
endif()
if(NOT $CACHE{CMAKE_INSTALL_LIBDIR} STREQUAL "lib")
  message(FATAL_ERROR "CACHE{CMAKE_INSTALL_LIBDIR} computed to '${CMAKE_INSTALL_LIBDIR}', but we expected 'lib' as we are in a CONDA env"
  )
endif()

# verify CMAKE_INSTALL_LIBDIR touched
if(NOT DEFINED CMAKE_INSTALL_LIBDIR)
  message(FATAL_ERROR "rapids_cmake_install_lib_dir should have caused the CMAKE_INSTALL_LIBDIR to be a local variable"
  )
endif()

# unset CMAKE_INSTALL_LIBDIR so it doesn't leak into our CMakeCache.txt and cause subsequent re-runs
# of the test to fail
unset(CMAKE_INSTALL_LIBDIR)
unset(CMAKE_INSTALL_LIBDIR CACHE)
