# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2024-2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)
set(CMAKE_CONFIGURATION_TYPES Debug)
project(rapids-test-project LANGUAGES CXX)

include(${rapids-cmake-dir}/rapids-test.cmake)

enable_testing()
rapids_test_init()

add_executable(verify_ main.cpp)
rapids_test_add(NAME verify
                COMMAND verify_
                GPUS 1
                PERCENT 100
                INSTALL_COMPONENT_SET testing)
add_library(callback SHARED callback.cpp)
rapids_test_record_install(TARGET callback COMPONENT testing)
add_executable(verify_args main_args.cpp)
target_link_libraries(verify_args PRIVATE ${CMAKE_DL_LIBS})
rapids_test_add(NAME verify_args
                COMMAND verify_args arg $<TARGET_FILE:callback>
                GPUS 1
                PERCENT 100
                INSTALL_COMPONENT_SET testing)
rapids_test_install_relocatable(INSTALL_COMPONENT_SET testing DESTINATION bin/tests/to_verify/)

add_custom_target(install_testing_component ALL
                  COMMAND ${CMAKE_COMMAND} --install "${CMAKE_CURRENT_BINARY_DIR}" --component
                          testing --prefix install/
                  COMMAND ${CMAKE_CTEST_COMMAND} --test-dir install/bin/tests/to_verify/
                          --output-on-failure --no-tests=error)
add_dependencies(install_testing_component callback verify_ verify_args generate_ctest_json)
