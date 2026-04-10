# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/rmm.cmake)

rapids_cpm_init()

rapids_cpm_rmm(INSTALL_EXPORT_SET example-exports)

# Call find_package which will trigger the FindPackageRedirect logic
find_package(rmm REQUIRED HINTS "${rmm_BINARY_DIR}")

rapids_cpm_rmm(BUILD_EXPORT_SET example-exports INSTALL_EXPORT_SET example-exports)

# verify that the expected path exists in cpm_rmm.cmake
set(path_rmm "${CMAKE_BINARY_DIR}/rapids-cmake/example-exports/build/cpm_rmm.cmake")
set(to_match_string "${rmm_BINARY_DIR}")

file(READ "${path_rmm}" contents)
message(FATAL_ERROR "${contents}")
string(FIND "${contents}" "${to_match_string}" is_found)
if(is_found EQUAL -1)
  message(FATAL_ERROR "rapids_cpm_cccl(BUILD_EXPORT_SET) failed to write out the proper possible_package_dir"
  )
endif()
