include(${rapids-cmake-dir}/export/find_package_file.cmake)

project(rapids-project LANGUAGES CUDA)

rapids_export_find_package_file(BUILD [=[${CMAKE_CURRENT_LIST_DIR}/fake/build/path]=] test_set)
