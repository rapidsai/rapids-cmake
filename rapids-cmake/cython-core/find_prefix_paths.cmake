# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cython_find_prefix_paths
-------------------------------

.. versionadded:: v26.02.00

Find all paths that should be added to CMAKE_PREFIX_PATH according to Python entry points.

.. code-block:: cmake

  rapids_cython_find_prefix_paths(<python_executable> <paths_var>)

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`<paths_var>` will be set to a list of
  paths that should be added to the prefix path.

#]=======================================================================]
function(rapids_cython_find_prefix_paths python_executable paths_var)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cython.init")

  set(_get_entry_points
[=[
import os
from importlib.metadata import entry_points
from importlib.resources import files

paths = []
for ep in entry_points(group="cmake.prefix"):
    p = files(ep.load())
    # Some entry_points expose a _paths attribute
    if hasattr(p, "_paths"):
        for s in p._paths:
            paths.append(os.fspath(s))
    else:
        paths.append(os.fspath(p))

print(";".join(f"{x}" for x in paths))
]=]
  )

  # Execute the Python at configure time and capture output
  execute_process(
      COMMAND ${python_executable} -c "${_get_entry_points}"
      OUTPUT_VARIABLE prefix_dirs
      OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  set(${paths_var} ${prefix_dirs} PARENT_SCOPE)

  list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()
