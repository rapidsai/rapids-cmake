# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)
project(rapids-test-project LANGUAGES NONE)

include(${rapids-cmake-dir}/test/add.cmake)

enable_testing()

# Use a fixed resource spec with a single GPU instead of `rapids_test_init` so that this test needs
# neither a CUDA toolkit nor any physical GPU.
add_test(NAME generate_resource_spec
         COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/resource_spec.json"
                 "${CMAKE_CURRENT_BINARY_DIR}/resource_spec.json")
set_tests_properties(generate_resource_spec
                     PROPERTIES FIXTURES_SETUP resource_spec GENERATED_RESOURCE_SPEC_FILE
                                "${CMAKE_CURRENT_BINARY_DIR}/resource_spec.json")

# All three allocations fit on the single GPU, so the test must see that GPU exactly once
rapids_test_add(NAME three_allocations_one_gpu
                COMMAND ${CMAKE_COMMAND} "-Dexpected_devices=0" -P
                        "${CMAKE_CURRENT_SOURCE_DIR}/verify_visible_devices.cmake"
                GPUS 3
                PERCENT 10)
