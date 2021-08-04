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

cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

include(FetchContent)
FetchContent_Declare(
  rapids-cmake
  GIT_REPOSITORY https://github.com/rapidsai/rapids-cmake.git
  GIT_TAG        origin/branch-21.06
  )
FetchContent_MakeAvailable(rapids-cmake)
include(rapids-cmake)
include(rapids-cpm)
include(rapids-cuda)
include(rapids-export)
include(rapids-find)

rapids_cuda_init_architectures(integration)

project(integration VERSION 21.06 LANGUAGES C CXX CUDA)
message(STATUS "Example: CMAKE_CUDA_ARCHITECTURES: ${CMAKE_CUDA_ARCHITECTURES}")

option(CUDA_STATIC_RUNTIME "Use CUDA static runtime" OFF)
# Set a default build type if none was specified
rapids_cmake_build_type(Release)

# Set the CUDA runtime CUDA targets will use
rapids_cuda_init_runtime(USE_STATIC ${CUDA_STATIC_RUNTIME})


# conda environment
rapids_cmake_support_conda_env( conda_env MODIFY_PREFIX_PATH )

# Find the CUDAToolkit
rapids_find_package(CUDAToolkit REQUIRED
                    BUILD_EXPORT_SET example-targets
                    INSTALL_EXPORT_SET example-targets
                    )

# find zlib using a find module we generate
rapids_find_generate_module(ZLIBS
    HEADER_NAMES        zlib.h
    LIBRARY_NAMES       z zlib
    BUILD_EXPORT_SET    example-targets
    INSTALL_EXPORT_SET  example-targets
    )

#Now use our generated find module and declar it part of
#our exported interface
find_package(ZLIBS REQUIRED)
rapids_export_package(INSTALL ZLIBS example-targets GLOBAL_TARGETS ZLIB::ZLIB)
rapids_export_package(BUILD ZLIBS example-targets)

# find Threads (needed by cudftestutil)
rapids_find_package(Threads REQUIRED
                    BUILD_EXPORT_SET example-targets
                    INSTALL_EXPORT_SET example-targets
                    )

rapids_cpm_init()


# This kind of API detaches us from having to encode each cpm module
# Is that useful?
rapids_cpm_find( rmm 0.20
                GLOBAL_TARGETS    rmm::rmm
                BUILD_EXPORT_SET  example-targets
                CPM_ARGS
                  GIT_REPOSITORY    https://github.com/rapidsai/rmm.git
                  GIT_TAG           branch-0.20
                  GIT_SHALLOW       TRUE
                  OPTIONS           "BUILD_TESTS OFF"
                                    "BUILD_BENCHMARKS OFF"
                                    "CUDA_STATIC_RUNTIME ${CUDA_STATIC_RUNTIME}"
                )

add_library(example source.cu)

set_target_properties(example
    PROPERTIES BUILD_RPATH                         "\$ORIGIN"
               INSTALL_RPATH                       "\$ORIGIN"
               # set target compile options
               CXX_STANDARD                        17
               CXX_STANDARD_REQUIRED               ON
               CUDA_STANDARD                       17
               CUDA_STANDARD_REQUIRED              ON
               POSITION_INDEPENDENT_CODE           ON
               INTERFACE_POSITION_INDEPENDENT_CODE ON
               )

target_link_libraries(example PUBLIC $<BUILD_INTERFACE:rmm::rmm> )

# Add Conda env exist s, use it for link and include dirs
if(TARGET conda_env)
  target_link_libraries(example PUBLIC $<BUILD_INTERFACE:conda_env> )
endif()

# - install targets -------------------------------------------------------------------------------

install(TARGETS example
        DESTINATION lib
        EXPORT example-targets
        )

################################################################################################
# - install export -------------------------------------------------------------------------------
set(doc_string
[=[
Provide targets for the example library.

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure
dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt
mollit anim id est laborum.

]=])

 rapids_export(INSTALL example
    EXPORT_SET example-targets
    GLOBAL_TARGETS example # since we can't hook into EXPORT SETS
    NAMESPACE example::
    DOCUMENTATION doc_string
    )

################################################################################################
# - build export -------------------------------------------------------------------------------
set(code_string
[=[
  message(STATUS "hi from example-config")
]=])
rapids_export(BUILD example
    EXPORT_SET example-targets
    GLOBAL_TARGETS example # since we can't hook into EXPORT SETS
    LANGUAGES CUDA
    DOCUMENTATION doc_string
    FINAL_CODE_BLOCK code_string
    )
