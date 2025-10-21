# =============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# =============================================================================

include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cython_verify_init
-------------------------

.. versionadded:: v24.02.00

Simple helper function for rapids-cython components to verify that rapids_cython_init has been called before they proceed.

.. code-block:: cmake

  rapids_cython_verify_init()

#]=======================================================================]
function(rapids_cython_verify_init)
  if(NOT DEFINED RAPIDS_CYTHON_INITIALIZED)
    message(FATAL_ERROR "You must call rapids_cython_init before calling this function")
  endif()
endfunction()
