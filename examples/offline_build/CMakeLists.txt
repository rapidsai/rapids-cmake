# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

cmake_minimum_required(VERSION 3.30.4 FATAL_ERROR)

project(offline_build_orchestration LANGUAGES NONE)

# Directories used by the offline build workflow
set(offline_cache_dir "${CMAKE_CURRENT_BINARY_DIR}/cpm_cache")
set(offline_build_dir "${CMAKE_CURRENT_BINARY_DIR}/offline-build")

# Populate the CPM source cache by building the project with network access. All dependency sources
# are downloaded into offline_cache_dir during this step.
execute_process(COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/generate_offline_source_cache.sh"
                        "${offline_cache_dir}" COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CMAKE_COMMAND}" -E touch "${offline_cache_dir}/.populated")

# Configure and build the project in fully offline mode using the populated cache.
# CPM_USE_LOCAL_PACKAGES is set by the script to prefer system-installed packages when available.
add_custom_command(OUTPUT "${offline_build_dir}/.built"
                   DEPENDS "${offline_cache_dir}/.populated"
                   COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/use_offline_source_cache.sh"
                           "${offline_cache_dir}" "${offline_build_dir}"
                   COMMAND "${CMAKE_COMMAND}" -E touch "${offline_build_dir}/.built"
                   COMMENT "Configuring and building project in offline mode"
                   VERBATIM)

# Build the offline project using its own build system.
add_custom_command(OUTPUT "${offline_build_dir}/offline_build_example"
                   DEPENDS "${offline_build_dir}/.built"
                   COMMAND "${CMAKE_COMMAND}" --build "${offline_build_dir}"
                   COMMENT "Building offline_build_example binary"
                   VERBATIM)

add_custom_target(offline_build_example ALL COMMENT "Building offline_build_example"
                  DEPENDS "${offline_build_dir}/offline_build_example")
