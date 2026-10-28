# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2025-2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

cmake_minimum_required(VERSION 4.0)

include(${rapids-cmake-dir}/cython-core/find_prefix_paths.cmake)

project(rapids_cython-find_prefix_path_test LANGUAGES C)

find_package(Python REQUIRED COMPONENTS Interpreter)

set(env_dir "${CMAKE_CURRENT_BINARY_DIR}/env")
file(REMOVE_RECURSE "${env_dir}")
execute_process(COMMAND ${Python_EXECUTABLE} -m "venv" "${env_dir}")

set(Python_EXECUTABLE "${env_dir}/bin/python")

execute_process(COMMAND "${Python_EXECUTABLE}" "-m" "pip" "install" "libucx-cu13")

set(_get_platlib
    [=[
import sysconfig
print(sysconfig.get_path("platlib"))
]=])

execute_process(COMMAND "${Python_EXECUTABLE}" "-c" "${_get_platlib}"
                OUTPUT_VARIABLE site_packages_path)
string(STRIP "${site_packages_path}" site_packages_path)
set(libucx_path "${site_packages_path}/libucx")

# pip writes bytecode at install time; remove it so we can check the helper writes none.
file(GLOB_RECURSE pycache_dirs LIST_DIRECTORIES true "${libucx_path}/*__pycache__")
file(REMOVE_RECURSE ${pycache_dirs})

rapids_cython_find_prefix_paths("${Python_EXECUTABLE}" prefix_paths)

if(NOT libucx_path IN_LIST prefix_paths)
  message(FATAL_ERROR "Expected to find libucx path '${libucx_path}' in prefix paths but did not.")
endif()

# Loading the entry points imports the packages. Writing their bytecode would leave files in the
# install prefix that end up in conda packages built with it.
file(GLOB_RECURSE pycache_files "${libucx_path}/*.pyc")
if(pycache_files)
  message(FATAL_ERROR "Expected no bytecode to be written but found: ${pycache_files}")
endif()
