# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2022-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)

if(DEFINED ENV{CTEST_RESOURCE_GROUP_COUNT})
  math(EXPR max_index "$ENV{CTEST_RESOURCE_GROUP_COUNT}-1")
  set(device_ids)
  # cmake-lint: disable=E1120
  foreach(index RANGE 0 "${max_index}")
    set(allocation $ENV{CTEST_RESOURCE_GROUP_${index}_GPUS})
    if(DEFINED allocation)
      # strings look like "id:value,slots:value" so let's make a super lazy parser by deleting `id:`
      # and replacing `,slots:` with `;` so we have a list with two items.
      string(REPLACE "id:" "" allocation "${allocation}")
      string(REPLACE ",slots:" ";" allocation "${allocation}")
      list(GET allocation 0 device_id)
      # slots are the cmake test requirements term for what we call percent, so we can ignore the
      # second item in the list
      list(APPEND device_ids ${device_id})
    endif()
  endforeach()
  # Each resource group holds one GPU allocation, so a test that requested multiple GPUs needs all
  # of them to be visible. Multiple allocations can land on the same GPU, so list each id once.
  list(REMOVE_DUPLICATES device_ids)
  list(LENGTH device_ids device_count)
  if(device_count GREATER 0)
    list(JOIN device_ids "," device_ids)
    set(ENV{CUDA_VISIBLE_DEVICES} "${device_ids}")
  endif()
endif()
execute_process(COMMAND ${command_to_run} ${command_args} COMMAND_ECHO STDOUT
                        COMMAND_ERROR_IS_FATAL ANY)
