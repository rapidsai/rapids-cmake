rapids-cmake
############

This is a collection of CMake modules that are useful for all CUDA RAPIDS
projects. By sharing the code in a single place it makes rolling out CMake
fixes easier.


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

