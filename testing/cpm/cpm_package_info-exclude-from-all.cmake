# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2025-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/package_override.cmake)

rapids_cpm_init()

# Define a test package via override so we don't need network access
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/override.json
     [=[
{
  "packages": {
    "test_pkg": {
      "version": "1.0.0",
      "git_url": "https://github.com/NVIDIA/test.git",
      "git_tag": "v1.0.0"
    },
    "test_pkg_efa_json": {
      "version": "2.0.0",
      "git_url": "https://github.com/NVIDIA/test2.git",
      "git_tag": "v2.0.0",
      "exclude_from_all": true
    },
    "test_pkg_efa_json_off": {
      "version": "3.0.0",
      "git_url": "https://github.com/NVIDIA/test3.git",
      "git_tag": "v3.0.0",
      "exclude_from_all": false
    }
  }
}
  ]=])

rapids_cpm_package_override(${CMAKE_CURRENT_BINARY_DIR}/override.json)

include("${rapids-cmake-dir}/cpm/detail/package_info.cmake")

# Test 1: EXCLUDE_FROM_ALL flag sets it to ON in CPM args
rapids_cpm_package_info(test_pkg EXCLUDE_FROM_ALL VERSION_VAR version CPM_VAR cpm_args
                        TO_INSTALL_VAR to_install)

list(FIND cpm_args "EXCLUDE_FROM_ALL" efa_idx)
if(efa_idx EQUAL -1)
  message(FATAL_ERROR "EXCLUDE_FROM_ALL not found in CPM args when flag was passed.\nGot: ${cpm_args}"
  )
endif()
math(EXPR efa_val_idx "${efa_idx} + 1")
list(GET cpm_args ${efa_val_idx} efa_value)
if(NOT efa_value STREQUAL "ON")
  message(FATAL_ERROR "Expected EXCLUDE_FROM_ALL=ON in CPM args, got: ${efa_value}")
endif()

# Test 2: EXCLUDE_FROM_ALL with INSTALL_EXPORT_SET should produce to_install=OFF
rapids_cpm_package_info(test_pkg EXCLUDE_FROM_ALL INSTALL_EXPORT_SET test_set VERSION_VAR version2
                        CPM_VAR cpm_args2 TO_INSTALL_VAR to_install2)
if(to_install2)
  message(FATAL_ERROR "Expected to_install=OFF when EXCLUDE_FROM_ALL is set with INSTALL_EXPORT_SET, got: ${to_install2}"
  )
endif()

# Test 3: Without EXCLUDE_FROM_ALL, default behavior preserved (value should be OFF)
rapids_cpm_package_info(test_pkg VERSION_VAR version3 CPM_VAR cpm_args3 TO_INSTALL_VAR to_install3)

list(FIND cpm_args3 "EXCLUDE_FROM_ALL" efa_idx3)
if(efa_idx3 EQUAL -1)
  message(FATAL_ERROR "EXCLUDE_FROM_ALL not found in default CPM args.\nGot: ${cpm_args3}")
endif()
math(EXPR efa_val_idx3 "${efa_idx3} + 1")
list(GET cpm_args3 ${efa_val_idx3} efa_value3)
if(NOT efa_value3 STREQUAL "OFF")
  message(FATAL_ERROR "Expected default EXCLUDE_FROM_ALL=OFF in CPM args, got: ${efa_value3}")
endif()

# Test 4: JSON exclude_from_all=true propagates to CPM args as ON
rapids_cpm_package_info(test_pkg_efa_json VERSION_VAR version4 CPM_VAR cpm_args4 TO_INSTALL_VAR
                        to_install4)

list(FIND cpm_args4 "EXCLUDE_FROM_ALL" efa_idx4)
if(efa_idx4 EQUAL -1)
  message(FATAL_ERROR "EXCLUDE_FROM_ALL not found in CPM args for JSON-sourced exclude.\nGot: ${cpm_args4}"
  )
endif()
math(EXPR efa_val_idx4 "${efa_idx4} + 1")
list(GET cpm_args4 ${efa_val_idx4} efa_value4)
if(NOT efa_value4 STREQUAL "ON")
  message(FATAL_ERROR "Expected EXCLUDE_FROM_ALL=ON from JSON data, got: ${efa_value4}")
endif()

# Test 5: JSON exclude_from_all=true with INSTALL_EXPORT_SET suppresses to_install
rapids_cpm_package_info(test_pkg_efa_json INSTALL_EXPORT_SET test_set VERSION_VAR version5 CPM_VAR
                        cpm_args5 TO_INSTALL_VAR to_install5)
if(to_install5)
  message(FATAL_ERROR "Expected to_install=OFF when JSON sets exclude_from_all=true with INSTALL_EXPORT_SET, got: ${to_install5}"
  )
endif()

# Test 6: Function arg EXCLUDE_FROM_ALL overrides JSON exclude_from_all=false
rapids_cpm_package_info(test_pkg_efa_json_off EXCLUDE_FROM_ALL VERSION_VAR version6 CPM_VAR
                        cpm_args6 TO_INSTALL_VAR to_install6)

list(FIND cpm_args6 "EXCLUDE_FROM_ALL" efa_idx6)
if(efa_idx6 EQUAL -1)
  message(FATAL_ERROR "EXCLUDE_FROM_ALL not found in CPM args.\nGot: ${cpm_args6}")
endif()
math(EXPR efa_val_idx6 "${efa_idx6} + 1")
list(GET cpm_args6 ${efa_val_idx6} efa_value6)
if(NOT efa_value6 STREQUAL "ON")
  message(FATAL_ERROR "Expected function arg to override JSON false to ON, got: ${efa_value6}")
endif()

# Test 7: JSON exclude_from_all=false without function flag stays OFF
rapids_cpm_package_info(test_pkg_efa_json_off VERSION_VAR version7 CPM_VAR cpm_args7 TO_INSTALL_VAR
                        to_install7)

list(FIND cpm_args7 "EXCLUDE_FROM_ALL" efa_idx7)
if(efa_idx7 EQUAL -1)
  message(FATAL_ERROR "EXCLUDE_FROM_ALL not found in CPM args.\nGot: ${cpm_args7}")
endif()
math(EXPR efa_val_idx7 "${efa_idx7} + 1")
list(GET cpm_args7 ${efa_val_idx7} efa_value7)
if(NOT efa_value7 STREQUAL "OFF")
  message(FATAL_ERROR "Expected JSON exclude_from_all=false to stay OFF, got: ${efa_value7}")
endif()
