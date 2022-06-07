# rapids-cmake 22.06.00 (Date TBD)

Please see https://github.com/rapidsai/rapids-cmake/releases/tag/v22.06.00a for the latest changes to this development branch.

# rapids-cmake 22.04.00 (Date TBD)

Please see https://github.com/rapidsai/rapids-cmake/releases/tag/v22.04.00a for the latest changes to this development branch.

# rapids-cmake 22.02.00 (Date TBD)

Please see https://github.com/rapidsai/rapids-cmake/releases/tag/v22.02.00a for the latest changes to this development branch.

# rapids-cmake 21.12.00 (Date TBD)

Please see https://github.com/rapidsai/rapids-cmake/releases/tag/v21.12.00a for the latest changes to this development branch.

# rapids-cmake 21.10.00 (7 Oct 2021)

## 🐛 Bug Fixes

- Remove unneeded inclusions of the old setup_cpm_cache.cmake (#82) @robertmaynard
- Make sure rapids-cmake doesn&#39;t produce CMake syntax warnings (#80) @robertmaynard
- rapids_export verify DOCUMENTATION and FINAL_CODE_BLOCK exist (#75) @robertmaynard
- Make sure rapids_cpm_spdlog specifies the correct spdlog global targets (#71) @robertmaynard
- rapids_cpm_thrust specifies the correct install variable (#70) @robertmaynard
- FIX Install sphinxcontrib-moderncmakedomain in docs script (#69) @dillon-cullinan
- rapids_export_cpm(BUILD) captures location of locally found packages (#65) @robertmaynard
- Introduce rapids_cmake_install_lib_dir (#61) @robertmaynard
- rapids_export(BUILD) only creates alias targets to existing targets (#55) @robertmaynard
- rapids_find_package propagates variables from find_package (#54) @robertmaynard
- rapids_cpm_find is more invariant as one would expect (#51) @robertmaynard
- rapids-cmake tests properly state what C++ std levels they require (#46) @robertmaynard
- rapids-cmake always generates GLOBAL_TARGETS names correctly (#36) @robertmaynard

## 📖 Documentation

- Update update-version.sh (#84) @raydouglass
- Add rapids_export_find_package_root to api doc page (#76) @robertmaynard
- README.md now references online docs (#72) @robertmaynard
- Copyright year range now matches when rapids-cmake existed (#67) @robertmaynard
- cmake-format: Now aware of `rapids_cmake_support_conda_env` flags (#62) @robertmaynard
- Bug/correct invalid generate module doc layout (#47) @robertmaynard

## 🚀 New Features

- rapids-cmake SHOULD_FAIL tests verify the CMake Error string (#79) @robertmaynard
- Introduce rapids_cmake_write_git_revision_file (#77) @robertmaynard
- Allow projects to override version.json information (#74) @robertmaynard
- rapids_export_package(BUILD) captures location of locally found packages (#68) @robertmaynard
- Introduce rapids_export_find_package_root command (#64) @robertmaynard
- Introduce rapids_cpm_&lt;preset&gt; (#52) @robertmaynard
- Tests now can be SERIAL and use FetchContent to get rapids-cmake (#48) @robertmaynard
- rapids_export version support expanded to handle more use-cases (#37) @robertmaynard

## 🛠️ Improvements

- cpm tests now download less components and can be run in parallel. (#81) @robertmaynard
- Ensure that all rapids-cmake files have include guards (#63) @robertmaynard
- Introduce RAPIDS.cmake a better way to fetch rapids-cmake (#45) @robertmaynard
- ENH Replace gpuci_conda_retry with gpuci_mamba_retry (#44) @dillon-cullinan

# rapids-cmake 21.08.00 (4 Aug 2021)


## 🚀 New Features

- Introduce `rapids_cmake_write_version_file` to generate a C++ version header ([#23](https://github.com/rapidsai/rapids-cmake/pull/23)) [@robertmaynard](https://github.com/robertmaynard)
- Introduce `cmake-format-rapids-cmake` to allow `cmake-format` to understand rapdids-cmake custom functions ([#29](https://github.com/rapidsai/rapids-cmake/pull/29)) [@robertmaynard](https://github.com/robertmaynard)

## 🛠️ Improvements


## 🐛 Bug Fixes

- ci/gpu/build.sh uses git tags to properly compute conda env (#43) @robertmaynard
- Make sure that rapids-cmake-dir cache variable is hidden (#40) @robertmaynard
- Correct regression specify rapids-cmake-dir as a cache variable (#39) @robertmaynard
- rapids-cmake add entries to CMAKE_MODULE_PATH on first config (#34) @robertmaynard
- Add tests that verify all paths in each rapids-<component>.cmake file ([#24](https://github.com/rapidsai/rapids-cmake/pull/24))  [@robertmaynard](https://github.com/robertmaynard)
- Correct issue where `rapids_export(DOCUMENTATION` content was being ignored([#30](https://github.com/rapidsai/rapids-cmake/pull/30))  [@robertmaynard](https://github.com/robertmaynard)
- rapids-cmake can now be correctly used by multiple adjacent directories ([#33](https://github.com/rapidsai/rapids-cmake/pull/33))  [@robertmaynard](https://github.com/robertmaynard)


# rapids-cmake 21.06.00 (Date TBD)

Please see https://github.com/rapidsai/rapids-cmake/releases/tag/v21.06.0a for the latest changes to this development branch.

## 🚀 New Features

- Introduce `rapids_cmake_parse_version` for better version extraction ([#20](https://github.com/rapidsai/rapids-cmake/pull/20)) [@robertmaynard](https://github.com/robertmaynard)

## 🛠️ Improvements

- Verify that rapids-cmake always preserves CPM arguments ([#18](https://github.com/rapidsai/rapids-cmake/pull/18))  [@robertmaynard](https://github.com/robertmaynard)
- Add Sphinx based documentation for the project  ([#14](https://github.com/rapidsai/rapids-cmake/pull/14))  [@robertmaynard](https://github.com/robertmaynard)
- `rapids_export` places the build export files in a location CPM can find. ([#3](https://github.com/rapidsai/rapids-cmake/pull/3))  [@robertmaynard](https://github.com/robertmaynard)

## 🐛 Bug Fixes

- Make sure we properly quote all CPM args ([#17](https://github.com/rapidsai/rapids-cmake/pull/17))  [@robertmaynard](https://github.com/robertmaynard)
- `rapids_export` correctly handles version strings with leading zeroes  ([#12](https://github.com/rapidsai/rapids-cmake/pull/12))  [@robertmaynard](https://github.com/robertmaynard)
- `rapids_export_write_language` properly executes each time CMake is run ([#10](https://github.com/rapidsai/rapids-cmake/pull/10))  [@robertmaynard](https://github.com/robertmaynard)
- `rapids_export` properly sets version variables ([#9](https://github.com/rapidsai/rapids-cmake/pull/9))  [@robertmaynard](https://github.com/robertmaynard)
- `rapids_export` now obeys CMake config file naming convention ([#8](https://github.com/rapidsai/rapids-cmake/pull/8))  [@robertmaynard](https://github.com/robertmaynard)
- Refactor layout to enable adding CI and Documentation ([#5](https://github.com/rapidsai/rapids-cmake/pull/5))  [@robertmaynard](https://github.com/robertmaynard)
