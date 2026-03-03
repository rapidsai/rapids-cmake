# rapids-cmake Examples

This directory contains examples demonstrating key features of rapids-cmake.

## Available Examples

### [project-bootstrap](project-bootstrap/)
Demonstrates the complete RAPIDS project initialization pattern used by ALL production RAPIDS projects:
- `VERSION` file - Project version in YY.MM.PP format
- `RAPIDS_BRANCH` file - rapids-cmake branch specification
- `cmake/rapids_config.cmake` - Parse version files and set variables
- `cmake/RAPIDS.cmake` - FetchContent-based rapids-cmake bootstrap

Shows how RAPIDS C++ projects are for set up for rapids-cmake. This is the first example you should read if you are wondering "How do I start a RAPIDS C++ project?".

### [conda-support](conda-support/)
Demonstrates conda environment integration for proper builds within conda:
- `rapids_cmake_support_conda_env()` - Create target with conda compile/link settings
- `MODIFY_PREFIX_PATH` - Automatically configure CMAKE_PREFIX_PATH for conda

Shows how to set up proper conda environment support including include directories, library paths, rpath-link, and build optimization overrides.

### [cuda-features](cuda-features/)
Demonstrates core CUDA-specific rapids-cmake features:
- `rapids_cuda_init_architectures()` - Initialize CUDA architectures before project()
- `rapids_cmake_build_type()` - Set default build type
- `rapids_cuda_init_runtime()` - Configure CUDA runtime (static/shared)
- `rapids_cuda_enable_fatbin_compression()` - Enable fatbin compression with proper TARGET usage

### [export-feature](export-feature/)
Demonstrates the rapids-cmake export system for creating reusable CMake packages:
- `rapids_export()` - Generate BUILD and INSTALL exports
- `rapids_find_package()` - Find dependencies and track in export sets
- `rapids_cpm_find()` - Fetch dependencies via CPM and add to export sets
- `rapids_cmake_install_lib_dir()` - CONDA-aware library installation directory

Shows how to create a library that can be consumed by downstream projects via find_package().

### [find-generate-module](find-generate-module/)
Demonstrates generating and installing FindModule files for dependencies without CMake support:
- `rapids_find_generate_module()` - Generate FindModule for packages lacking CMake config
- Export FindModules with your package for downstream dependency resolution

Shows how projects can generate a custom Find Module to locate a dependency. Shows how to install said Find Module, so that downstream packages that depend on non-CMake-aware libraries will not fail to configure.

### [project-override](project-override/)
Demonstrates conditional dependency version overrides using CMake presets:
- `RAPIDS_CMAKE_CPM_OVERRIDE_VERSION_FILE` - CMake variable to specify override file
- `override.json` - JSON file specifying custom dependency versions (e.g., CCCL)
- `CMakePresets.json` - Presets with and without overrides enabled

Shows how to conditionally enable dependency overrides based on the selected CMake preset. The `default` preset uses standard versions, while `with-override` applies custom versions from override.json.

### [version-header](version-header/)
Demonstrates generating C++ version headers from CMake project version:
- `rapids_cmake_write_version_file()` - Generate version header with macros
- Integration with project() VERSION command
- Version information accessible at runtime in C++ code

Shows how to make project version available to C++ code through generated headers. This pattern is used by ALL RAPIDS projects (RMM, cuDF, cuVS) to provide version information for runtime checks, logging, and compatibility verification.

### [third-party-dependencies](third-party-dependencies/)
Demonstrates the cmake/thirdparty/ organization pattern for managing dependencies at scale:
- `cmake/thirdparty/get_fmt.cmake` - Simple dependency pattern (like cuVS's hnswlib)
- `cmake/thirdparty/get_spdlog.cmake` - Dependency with custom PATCH_COMMAND
- One file per dependency for organization and maintainability

Shows the professional dependency organization pattern used by ALL RAPIDS projects. This pattern scales from small projects to large ones (cuDF manages 15+ dependencies this way). Critical for maintainability as projects grow.

### [pin-dependencies](pin-dependencies/)
Demonstrates dependency pinning for reproducible builds:
- `rapids_cpm_init(GENERATE_PINNED_VERSIONS)` - Generate pinned versions file
- `pins.json` - Lock dependency versions for reproducibility
- CMakePresets.json - Presets with and without pinned dependencies
- `update_pins.sh` - Script to regenerate pinned versions

Shows how to generate and use pinned dependency versions for reproducible builds.

## Building Examples

Each example can be built independently:

```bash
cd <example-directory>
cmake -S . -B build
cmake --build build
```

Some examples provide CMake presets:

```bash
cd <example-directory>
cmake --preset <preset-name>
cmake --build --preset <preset-name>
```

## Requirements

- CMake 3.30.4 or later
- CUDA Toolkit
- C++17 compatible compiler
