# rapids-cmake 22.12.00 (8 Dec 2022)

## 🐛 Bug Fixes

- Don&#39;t use CMake 3.25.0 as it has a show stopping FindCUDAToolkit bug ([#308](https://github.com/rapidsai/rapids-cmake/pull/308)) [@robertmaynard](https://github.com/robertmaynard)
- Add missing CPM_ARGS to gbench ([#294](https://github.com/rapidsai/rapids-cmake/pull/294)) [@vyasr](https://github.com/vyasr)
- Patch results are only displayed once per invocation of CMake ([#292](https://github.com/rapidsai/rapids-cmake/pull/292)) [@robertmaynard](https://github.com/robertmaynard)
- Add thrust output iterator fix to rapids-cmake thrust patches ([#291](https://github.com/rapidsai/rapids-cmake/pull/291)) [@robertmaynard](https://github.com/robertmaynard)

## 📖 Documentation

- Update pull request template to match rest of RAPIDS ([#280](https://github.com/rapidsai/rapids-cmake/pull/280)) [@robertmaynard](https://github.com/robertmaynard)
- Clarify rapids_cuda_init_architectures behavior ([#279](https://github.com/rapidsai/rapids-cmake/pull/279)) [@robertmaynard](https://github.com/robertmaynard)

## 🚀 New Features

- Update cuco git tag ([#302](https://github.com/rapidsai/rapids-cmake/pull/302)) [@PointKernel](https://github.com/PointKernel)
- Remove old CI files ([#300](https://github.com/rapidsai/rapids-cmake/pull/300)) [@robertmaynard](https://github.com/robertmaynard)
- Update cuco to version that supports Ada and Hopper ([#299](https://github.com/rapidsai/rapids-cmake/pull/299)) [@robertmaynard](https://github.com/robertmaynard)
- Move libcudacxx 1.8.1 so we support sm90 ([#296](https://github.com/rapidsai/rapids-cmake/pull/296)) [@robertmaynard](https://github.com/robertmaynard)
- Add ability to specify library directories for target rpaths ([#295](https://github.com/rapidsai/rapids-cmake/pull/295)) [@vyasr](https://github.com/vyasr)
- Add support for cloning Google benchmark ([#293](https://github.com/rapidsai/rapids-cmake/pull/293)) [@vyasr](https://github.com/vyasr)
- Add `current_json_dir` placeholder in json patch file values ([#289](https://github.com/rapidsai/rapids-cmake/pull/289)) [@robertmaynard](https://github.com/robertmaynard)
- Add sm90 ( Hopper ) to rapids-cmake &quot;ALL&quot; mode ([#285](https://github.com/rapidsai/rapids-cmake/pull/285)) [@robertmaynard](https://github.com/robertmaynard)
- Enable copy_prs ops-bot config ([#284](https://github.com/rapidsai/rapids-cmake/pull/284)) [@robertmaynard](https://github.com/robertmaynard)
- Add GitHub action workflow to rapids-cmake ([#283](https://github.com/rapidsai/rapids-cmake/pull/283)) [@robertmaynard](https://github.com/robertmaynard)
- Create conda package of patched dependencies ([#275](https://github.com/rapidsai/rapids-cmake/pull/275)) [@robertmaynard](https://github.com/robertmaynard)
- Switch thrust over to use rapids-cmake patches ([#265](https://github.com/rapidsai/rapids-cmake/pull/265)) [@robertmaynard](https://github.com/robertmaynard)

## 🛠️ Improvements

- Remove `rapids-dependency-file-generator` `FIXME` ([#305](https://github.com/rapidsai/rapids-cmake/pull/305)) [@ajschmidt8](https://github.com/ajschmidt8)
- Add `ninja` as build dependency ([#301](https://github.com/rapidsai/rapids-cmake/pull/301)) [@ajschmidt8](https://github.com/ajschmidt8)
- Forward merge 22.10 into 22.12 ([#297](https://github.com/rapidsai/rapids-cmake/pull/297)) [@vyasr](https://github.com/vyasr)

# rapids-cmake 22.10.00 (12 Oct 2022)

## 🚨 Breaking Changes

- Update rapids-cmake to require cmake 3.23.1 (#227) @robertmaynard
- put $PREFIX before $BUILD_PREFIX in conda build (#182) @kkraus14

## 🐛 Bug Fixes

- Update to nvcomp 2.4.1 to fix zstd decompression (#286) @robertmaynard
- Restore rapids_cython_create_modules output variable name (#276) @robertmaynard
- rapids_cuda_init_architectures now obeys CUDAARCHS env variable (#270) @robertmaynard
- Update to Thrust 1.17.2 to fix cub ODR issues (#269) @robertmaynard
- conda_env: pass conda prefix as a rpath-link directory (#263) @robertmaynard
- Update cuCollections to fix issue with INSTALL_CUCO set to OFF. (#261) @bdice
- rapids_cpm_libcudacxx correct location of libcudacxx-config (#258) @robertmaynard
- Update rapids_find_generate_module to cmake 3.23 (#256) @robertmaynard
- Handle reconfiguring with USE_PROPRIETARY_BINARY value differing (#255) @robertmaynard
- rapids_cpm_thrust record build directory location of thrust-config (#254) @robertmaynard
- disable cuco install rules when no INSTALL_EXPORT_SET (#250) @robertmaynard
- Patch thrust and cub install rules to have proper header searches (#244) @robertmaynard
- Ensure that we install Thrust and Cub correctly. (#243) @robertmaynard
- Revert &quot;Update to CPM v0.35.4 for URL downloads... (#236)&quot; (#242) @robertmaynard
- put $PREFIX before $BUILD_PREFIX in conda build (#182) @kkraus14

## 📖 Documentation

- Correct broken patch_toolkit API docs, and CMake API cross references (#271) @robertmaynard
- Provide suggestions when encountering an incomplete GTest package (#247) @robertmaynard
- Docs: RAPIDS.cmake should be placed in current bin dir (#241) @robertmaynard
- Remove incorrect install location note on rapids_export (#232) @robertmaynard

## 🚀 New Features

- Update to CPM 0.35.6 as it has needed changes for cpm patching support. (#273) @robertmaynard
- Update to nvcomp 2.4 which now offers aarch64 binaries! (#272) @robertmaynard
- Support the concept of a patches to apply to a project built via CPM (#264) @robertmaynard
- Branch 22.10 merge 22.08 (#262) @robertmaynard
- Introduce rapids_cuda_patch_toolkit (#260) @robertmaynard
- Update libcudacxx to 1.8 (#253) @robertmaynard
- Update to CPM version 0.35.5 (#249) @robertmaynard
- Update to CPM v0.35.4 for URL downloads match the download time (#236) @robertmaynard
- rapids-cmake dependency tracking now understands COMPONENTS (#234) @robertmaynard
- Update to thrust 1.17 (#231) @robertmaynard
- Update to CPM v0.35.3 to support symlink build directories (#230) @robertmaynard
- Update rapids-cmake to require cmake 3.23.1 (#227) @robertmaynard
- Improve GPU detection by doing less subsequent executions (#222) @robertmaynard

## 🛠️ Improvements

- Fix typo in `rapids-cmake-url` (#267) @trxcllnt
- Ensure `&lt;pkg&gt;_FOUND` is set in the generated `Find&lt;pkg&gt;.cmake` file (#266) @trxcllnt
- Set `CUDA_USE_STATIC_CUDA_RUNTIME` to control legacy `FindCUDA.cmake`behavior (#259) @trxcllnt
- Use the GitHub `.zip` URI instead of `GIT_REPOSITORY` and `GIT_BRANCH` (#257) @trxcllnt
- Update nvcomp to 2.3.3 (#221) @vyasr

# rapids-cmake 22.08.00 (17 Aug 2022)

## 🐛 Bug Fixes

- json exclude flag behaves as expected libcudacx//thrust/nvcomp ([#223](https://github.com/rapidsai/rapids-cmake/pull/223)) [@robertmaynard](https://github.com/robertmaynard)
- Remove nvcomp dependency on CUDA::cudart_static ([#218](https://github.com/rapidsai/rapids-cmake/pull/218)) [@robertmaynard](https://github.com/robertmaynard)
- Timestamps for URL downloads match the download time ([#215](https://github.com/rapidsai/rapids-cmake/pull/215)) [@robertmaynard](https://github.com/robertmaynard)
- Revert &quot;Update nvcomp to 2.3.2 ([#209)&quot; (#210](https://github.com/rapidsai/rapids-cmake/pull/209)&quot; (#210)) [@vyasr](https://github.com/vyasr)
- rapids-cmake won&#39;t ever use an existing variable starting with RAPIDS_ ([#203](https://github.com/rapidsai/rapids-cmake/pull/203)) [@robertmaynard](https://github.com/robertmaynard)

## 📖 Documentation

- Docs now provide rapids_find_package examples ([#220](https://github.com/rapidsai/rapids-cmake/pull/220)) [@robertmaynard](https://github.com/robertmaynard)
- Minor typo fix in api.rst ([#207](https://github.com/rapidsai/rapids-cmake/pull/207)) [@vyasr](https://github.com/vyasr)
- rapids_cpm_&lt;pkgs&gt; document handling of unparsed args ([#206](https://github.com/rapidsai/rapids-cmake/pull/206)) [@robertmaynard](https://github.com/robertmaynard)
- Docs/remove doc warnings ([#205](https://github.com/rapidsai/rapids-cmake/pull/205)) [@robertmaynard](https://github.com/robertmaynard)
- Fix docs: default behavior is to use a shallow git clone. ([#204](https://github.com/rapidsai/rapids-cmake/pull/204)) [@bdice](https://github.com/bdice)
- Add rapids_cython to the html docs ([#197](https://github.com/rapidsai/rapids-cmake/pull/197)) [@robertmaynard](https://github.com/robertmaynard)

## 🚀 New Features

- More robust solution of CMake policy 135 ([#224](https://github.com/rapidsai/rapids-cmake/pull/224)) [@robertmaynard](https://github.com/robertmaynard)
- Update cuco git tag ([#213](https://github.com/rapidsai/rapids-cmake/pull/213)) [@PointKernel](https://github.com/PointKernel)
- Revert &quot;Revert &quot;Update nvcomp to 2.3.2 ([#209)&quot; (#210)&quot; (#211](https://github.com/rapidsai/rapids-cmake/pull/209)&quot; (#210)&quot; (#211)) [@vyasr](https://github.com/vyasr)
- Update nvcomp to 2.3.2 ([#209](https://github.com/rapidsai/rapids-cmake/pull/209)) [@robertmaynard](https://github.com/robertmaynard)
- rapids_cpm_rmm no longer install when no INSTALL_EXPORT_SET listed ([#202](https://github.com/rapidsai/rapids-cmake/pull/202)) [@robertmaynard](https://github.com/robertmaynard)
- Adds support for pulling cuCollections using rapids-cmake ([#201](https://github.com/rapidsai/rapids-cmake/pull/201)) [@vyasr](https://github.com/vyasr)
- Add support for a prefix in Cython module targets ([#198](https://github.com/rapidsai/rapids-cmake/pull/198)) [@vyasr](https://github.com/vyasr)

## 🛠️ Improvements

- `rapids_find_package()` called with explicit version and REQUIRED should fail ([#214](https://github.com/rapidsai/rapids-cmake/pull/214)) [@trxcllnt](https://github.com/trxcllnt)

# rapids-cmake 22.06.00 (7 June 2022)

## 🐛 Bug Fixes

- nvcomp install rules need to match the pre-built layout (#194) @robertmaynard
- Use target name variable. (#187) @bdice
- Remove uneeded message from rapids_export_package (#183) @robertmaynard
- rapids_cpm_thrust: Correctly find version 1.15.0 (#181) @robertmaynard
- rapids_cpm_thrust: Correctly find version 1.15.0 (#180) @robertmaynard

## 📖 Documentation

- Correct spelling mistake in cpm package docs (#188) @robertmaynard

## 🚀 New Features

- Add rapids_cpm_nvcomp with prebuilt binary support (#190) @robertmaynard
- Default Cython module RUNPATH to $ORIGIN and return the list of created targets (#189) @vyasr
- Add rapids-cython component for scikit-build based Python package builds (#184) @vyasr
- Add more exhaustive set of tests are version values of 0 (#178) @robertmaynard
- rapids_cpm_package_override now hooks into FetchContent (#164) @robertmaynard

## 🛠️ Improvements

- Update nvbench tag (#193) @PointKernel

# rapids-cmake 22.04.00 (6 Apr 2022)

## 🐛 Bug Fixes

- rapids_export now handles explicit version values of 0 correctly (#174) @robertmaynard
- rapids_export now internally uses better named variables (#172) @robertmaynard
- rapids_cpm_gtest will properly find GTest 1.10 packages (#168) @robertmaynard
- CMAKE_CUDA_ARCHITECTURES `ALL` will not insert 62 or 72 (#161) @robertmaynard
- Tracked package versions are now not required, but preferred. (#160) @robertmaynard
- cpm_thrust would fail when provided only an install export set (#155) @robertmaynard
- rapids_export generated config.cmake no longer leaks variables (#149) @robertmaynard

## 📖 Documentation

- Docs use intersphinx correctly to link to CMake command docs (#159) @robertmaynard
- Example explains when you should use `rapids_find_generate_module` (#153) @robertmaynard
- Add CMake intersphinx support (#147) @bdice

## 🚀 New Features

- Bump CPM 0.35 for per package CPM_DOWNLOAD controls (#158) @robertmaynard
- Track package versions to the generated `find_dependency` calls (#156) @robertmaynard
- Update to latest nvbench (#150) @robertmaynard

## 🛠️ Improvements

- Temporarily disable new `ops-bot` functionality (#170) @ajschmidt8
- Use exact gtest version (#165) @trxcllnt
- Add `.github/ops-bot.yaml` config file (#163) @ajschmidt8

# rapids-cmake 22.02.00 (2 Feb 2022)

## 🐛 Bug Fixes

- Ensure that nvbench doesn&#39;t require nvml when `CUDA::nvml` doesn&#39;t exist (#146) @robertmaynard
- rapids_cpm_libcudacxx handle CPM already finding libcudacxx before being called (#130) @robertmaynard

## 📖 Documentation

- Fix typos (#142) @ajschmidt8
- Fix type-o in docs `&lt;PackageName&gt;_BINARY_DIR` instead of `&lt;PackageName&gt;_BINAR_DIR` (#140) @dagardner-nv
- Set the `always_download` value in versions.json to the common case (#135) @robertmaynard
- Update Changelog to capture all 21.08 and 21.10 changes (#134) @robertmaynard
- Correct minor formatting issues (#132) @robertmaynard
- Document how to control the git rep/tag that RAPIDS.cmake uses (#131) @robertmaynard

## 🚀 New Features

- rapids-cmake now supports an empty package entry in the override file (#145) @robertmaynard
- Update NVBench for 22.02 to be the latest version (#144) @robertmaynard
- Update rapids-cmake packages to libcudacxx 1.7 (#143) @robertmaynard
- Update rapids-cmake packages to Thrust 1.15 (#138) @robertmaynard
- add exclude_from_all flag to version.json (#137) @robertmaynard
- Add `PREFIX` option to write_version_file / write_git_revision_file (#118) @robertmaynard

## 🛠️ Improvements

- Remove rapids_cmake_install_lib_dir unstable side effect checks (#136) @robertmaynard

# rapids-cmake 21.12.00 (9 Dec 2021)

## 🐛 Bug Fixes

- rapids_cpm_libcudacxx install logic is safe for multiple inclusion (#124) @robertmaynard
- rapids_cpm_libcudacxx ensures CMAKE_INSTALL_INCLUDEDIR exists (#122) @robertmaynard
- rapids_cpm_find restores CPM variables when project was already added (#121) @robertmaynard
- rapids_cpm_thrust doesn&#39;t place temp file in a searched location (#120) @robertmaynard
- Require the exact version of Thrust in the versions.json file (#119) @trxcllnt
- CMake option second parameter is the help string, not the default value (#114) @robertmaynard
- Make sure we don&#39;t do a shallow clone on nvbench (#113) @robertmaynard
- Pin NVBench to a known working SHA1 (#112) @robertmaynard
- Build directory config.cmake now sets the correct targets to global (#110) @robertmaynard
- rapids_cpm_thrust installs to a location that won&#39;t be marked system (#98) @robertmaynard
- find_package now will find modules that CPM has downloaded. (#96) @robertmaynard
- rapids_cpm_thrust dont export namespaced thrust target (#93) @robertmaynard
- rapids_cpm_spdlog specifies the correct install variable (#91) @robertmaynard
- rapids_cpm_init: `CPM_SOURCE_CACHE` doesn&#39;t mean the CPM file exists (#87) @robertmaynard

## 📖 Documentation

- Better document that rapids_cpm_find supports abitrary projects (#108) @robertmaynard
- Update the example to showcase rapids-cmake 21.12 (#107) @robertmaynard
- Properly generate rapids_cuda_init_runtime docs (#106) @robertmaynard

## 🚀 New Features

- Introduce rapids_cpm_libcudacxx (#111) @robertmaynard
- Record formatting rules for rapids_cpm_find DOWNLOAD_ONLY option (#94) @robertmaynard
- rapids_cmake_install_lib_dir now aware of GNUInstallDirs improvements in CMake 3.22 (#85) @robertmaynard
- rapids-cmake defaults to always download overriden packages (#83) @robertmaynard

## 🛠️ Improvements

- Prefer `CPM_&lt;pkg&gt;_SOURCE` dirs over `find_package()` in `rapids_cpm_find` (#92) @trxcllnt

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
