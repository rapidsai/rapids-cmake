# `gersemi-rapids-cmake`

This is a [Gersemi](https://github.com/BlankSpruce/gersemi) extension for
RAPIDS. It includes all CMake definitions present in:

  - [rapids-cmake](https://github.com/rapidsai/rapids-cmake)
  - [rapids-logger](https://github.com/rapidsai/rapids-logger)
  - [CPM](https://github.com/cpm-cmake/CPM.cmake)

To use it, run:

```shell
pip install gersemi-rapids-cmake
gersemi -i --extensions rapids_cmake -- CMakeLists.txt
```

To use the extension in pre-commit, add the following to your
`.pre-commit-config.yaml` file:

```yaml
repos:
  - repo: https://github.com/BlankSpruce/gersemi
    rev: 0.23.2
    hooks:
      - id: gersemi
        args: [-i, --extensions, rapids_cmake, --]
        additional_dependencies:
          - gersemi-rapids-cmake
```
