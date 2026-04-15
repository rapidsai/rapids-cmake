# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/cccl.cmake)

rapids_cpm_init()

# First time without export set so that rapids_export_cpm doesn't record a location
rapids_cpm_cccl()

# Call find_package which will trigger the FindPackageRedirect logic
find_package(CCCL ${CCCL_VERSION} CONFIG REQUIRED)

# Second time with an export set so that rapids_export_cpm now records a location
rapids_cpm_cccl(BUILD_EXPORT_SET example-exports INSTALL_EXPORT_SET example-exports)

# verify that the expected path exists in also_fake_cpm_package.cmake
set(path "${CMAKE_BINARY_DIR}/rapids-cmake/example-exports/build/cpm_CCCL.cmake")
set(to_match_string "CMakeFiles/pkgRedirects")

file(READ "${path}" contents)
string(FIND "${contents}" "${to_match_string}" is_found)
if(NOT is_found EQUAL -1)
  message(FATAL_ERROR "rapids_cpm_cccl(BUILD_EXPORT_SET) failed to write out the proper possible_package_dir"
  )
endif()
