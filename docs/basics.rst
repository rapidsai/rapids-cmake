RAPIDS-CMake Basics
###################


Installation
************

The ``rapids-cmake`` module is designed to be acquired via CMake's `Fetch
Content <https://cmake.org/cmake/help/latest/module/FetchContent.html>`_ into your project.

.. code-block:: cmake

  cmake_minimum_required(...)

  include(FetchContent)
  FetchContent_Declare(
    rapids-cmake
    GIT_REPOSITORY https://github.com/rapidsai/rapids-cmake.git
    GIT_TAG        branch-<VERSION_MAJOR>.<VERSION_MINOR>
  )
  FetchContent_MakeAvailable(rapids-cmake)
  include(rapids-cmake)
  include(rapids-cpm)
  include(rapids-cuda)
  include(rapids-export)
  include(rapids-find)

  project(...)

Usage
*****

``rapids-cmake`` is designed for projects to use only the subset of features that they need. To enable
this the project is decomposed in the following primary components:

- `cmake <api.html#common>`__
- `cpm <api.html#cpm>`__
- `cuda <api.html#cuda>`__
- `export <api.html#export>`__
- `find <api.html#find>`__

To use function provided by ``rapids-cmake`` projects have two options:

- Call ``include(rapids-<component>)`` which imports commonly used functions for the component
- Load each function independently via ``include(${rapids-cmake-dir}/<component>/<function_name>.cmake)``
