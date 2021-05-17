# <div align="left"><img src="https://rapids.ai/assets/images/rapids_logo.png" width="90px"/>&nbsp;rapids-cmake</div>

**NOTE:** For the latest stable [README.md](https://github.com/rapidsai/rapids-cmake/blob/main/README.md) ensure you are on the `main` branch.

## Overview

This is a collection of CMake modules that are useful for all CUDA RAPIDS
projects. By sharing the code in a single place it makes rolling out CMake
fixes easier.


## Installation

The `rapids-cmake` module is designed to be acquired via CMake's [Fetch
Content](https://cmake.org/cmake/help/latest/module/FetchContent.html) into your project.

```cmake

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

project(....)
```

Note that we recommend you install `rapids-cmake` into the root `CMakeLists.txt` of
your project before the first `project` call. This allows us to offer features such as
`rapids_cuda_architectures()`

## Usage

`rapids-cmake` provides a collection of useful CMake settings that any RAPIDS project may use.
While they maybe common, we know that they aren't universal and might need to be composed in
different ways.

To use function provided by `rapids-cmake` projects have two options:
- Call `include(rapids-<component>)` as that imports all commonly used functions for that component
- Load each function independently via `include(${rapids-cmake-dir}/<component>/<function_name>.cmake)`


## Components

Complete online documentation for all components is currently under development. Currently
you can read the existing documentation by looking at the inline restructure text of
each cmake file.

### cmake
The `rapids-cmake` module contains helpful general CMake functionality

- `rapids_cmake_build_type( )` handles initialization of `CMAKE_BUILD_TYPE`
- `rapids_cmake_support_conda_env( target [MODIFY_PREFIX_PATH])` Establish a target that holds the CONDA enviornment
  include and link directories.

### cpm

The `rapids-cpm` module contains CPM functionality to allow projects to acquire dependencies consistently.
For consistentcy All targets brought in via `rapids-cpm` are GLOBAL targets.

- `raipds_cpm_init()` handles initialization of the CPM module.
- `raipds_cpm_find(<project> name BUILD_EXPORT_SET <name> INSTALL_EXPORT_SET <name>)` Will search for a module and fall back to installing via CPM. Offers support to track dependencies for easy package exporting

### cuda

The `rapids-cuda` module contains core functionality to allow projects to build CUDA code robustly.
The most commonly used function are:

- `rapids_cuda_init_architectures(<project_name>)` handles initialization of `CMAKE_CUDA_ARCHITECTURE`. MUST BE CALLED BEFORE `PROJECT()`
- `rapids_cuda_init_runtime(<mode>)` handles initialization of `CMAKE_CUDA_RUNTIME_LIBRARY`.

### export

The `rapids-export` module contains core functionality to allow projects to easily record and write out
build and install dependencies, that come from `find_package` or `cpm`

- `rapids_export(<type> <project> EXPORT_SET <name>)` write out all the require components of a
  projects config module so that the `install` or `build` directory can be imported via `find_package`. See `rapids_export` documentation for full documentation


### find

The `rapids-find` module contains core functionality to allow projects to easily generate FindModule
or export `find_package` calls:

The most commonly used function are:

- `rapids_find_package(<project_name> BUILD_EXPORT_SET <name> INSTALL_EXPORT_SET <name> )` Combines `find_package` and support to track dependencies for easy package exporting
- `rapids_generate_module(<PackageName> HEADER_NAMES <paths...> LIBRARY_NAMES <names...> )` Generate a FindModule for the given package. Allows association to export sets so the generated FindModule can be shipped with the project


## Contributing

Review the [CONTRIBUTING.md](https://github.com/rapidsai/rapids-cmake/blob/main/CONTRIBUTING.md) file for information on how to contribute code and issues to the project.
