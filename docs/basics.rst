RAPIDS-CMake Basics
###################


Installation
************

The ``rapids-cmake`` module is designed to be acquired at configure time in your project.
Download the ``RAPIDS.cmake`` script, which handles fetching the rest of the module's content
via CMake's `FetchContent <https://cmake.org/cmake/help/latest/module/FetchContent.html>`_.

.. code-block:: cmake

  cmake_minimum_required(...)

  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/<PROJ>_RAPIDS.cmake)
    file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/branch-24.10/RAPIDS.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/<PROJ>_RAPIDS.cmake)
  endif()
  include(${CMAKE_CURRENT_BINARY_DIR}/<PROJ>_RAPIDS.cmake)
  include(rapids-cmake)
  include(rapids-cpm)
  include(rapids-cuda)
  include(rapids-export)
  include(rapids-find)

  project(...)

Usage
*****

``rapids-cmake`` is designed for projects to use only the subset of features that they need. To enable
this ``rapids-cmake`` comprises the following primary components:

- :ref:`cmake <common>`
- :ref:`cpm <cpm>`
- :ref:`cython <cython>`
- :ref:`cuda <cuda>`
- :ref:`export <export>`
- :ref:`find <find>`
- :ref:`testing <testing>`

There are two ways projects can use ``rapids-cmake`` functions.

1. Call ``include(rapids-<component>)``, which imports commonly used functions for the component.
2. Load each function independently via ``include(${rapids-cmake-dir}/<component>/<function_name>.cmake)``.

Overriding RAPIDS.cmake
***********************

At times projects or developers will need to verify ``rapids-cmake`` branches. To do this you can set variables that control which repository ``RAPIDS.cmake`` downloads, which should be done like this:

```cmake
  # To override the version that is pulled:
  set(rapids-cmake-version "<version>")
  include(FetchContent)
  FetchContent_Declare(
    rapids-cmake
    GIT_REPOSITORY https://github.com/<my_fork>/rapids-cmake.git
    GIT_TAG        <my_feature_branch>
  )
  file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/branch-21.12/RAPIDS.cmake
  # To override the GitHub repository:
  set(rapids-cmake-repo "<my_fork>")
  # To use an exact Git SHA:
  set(rapids-cmake-sha "<my_git_sha>")
  # To use a Git tag:
  set(rapids-cmake-tag "<my_git_tag>")
  # To override the repository branch:
  set(rapids-cmake-branch "<my_feature_branch>")
  # Or to override the entire repository URL (e.g. to use a GitLab repo):
  set(rapids-cmake-url "https://gitlab.com/<my_user>/<my_fork>/-/archive/<my_branch>/<my_fork>-<my_branch>.zip")
  file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/branch-22.10/RAPIDS.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
  include(${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
```

This tells ``FetchContent`` to ignore the explicit url and branch in ``RAPIDS.cmake`` and use the
ones provided.
A few notes:

- An explicitly defined ``rapids-cmake-url`` will always be used
- `rapids-cmake-sha` takes precedence over `rapids-cmake-tag`
- `rapids-cmake-tag` takes precedence over `rapids-cmake-branch`
- It is advised to always set `rapids-cmake-version` to the version expected by the repo your modifications will pull

An incorrect approach that people try is to modify the ``file(DOWNLOAD)`` line to point to the
custom ``rapids-cmake`` branch. That doesn't work as the downloaded ``RAPIDS.cmake`` contains
which version of the rapids-cmake repository to clone.
