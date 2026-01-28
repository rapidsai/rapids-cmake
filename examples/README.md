# rapids-cmake Examples

This directory contains examples demonstrating key features of rapids-cmake.

## Available Examples

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

Shows how to create a library that can be consumed by downstream projects via find_package().

### [project-override](project-override/)
Demonstrates conditional dependency version overrides using CMake presets:
- `RAPIDS_CMAKE_CPM_OVERRIDE_VERSION_FILE` - CMake variable to specify override file
- `override.json` - JSON file specifying custom dependency versions (e.g., CCCL)
- `CMakePresets.json` - Presets with and without overrides enabled

Shows how to conditionally enable dependency overrides based on the selected CMake preset. The `default` preset uses standard versions, while `with-override` applies custom versions from override.json.

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
