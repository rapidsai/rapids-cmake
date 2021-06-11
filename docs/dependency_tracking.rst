
Dependency Tracking
###################

One of the biggest features of rapids-cmake is that is can track dependencies ( `find_package`, `cpm` )
allowing for projects to easily generate `<project>-config.cmake` files with correct dependency requirements.
In a normal CMake project public dependencies need to be recorded in two locations, the original ``CMakeLists.txt`` file and also the generated `<project>-config.cmake`. This dual source of truth increases
developer burden, and adds a common source of error.

``rapids-cmake`` is designed to remove this dual source of truth by expanding the concept of Modern CMake `Usage Requirements https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-specification-and-usage-requirements`_  to include external packages.
This is done via the ``BUILD_EXPORT_SET`` ( maps to  `<BUILD_INTERFACE>` ) and ``INSTALL_EXPORT_SET`` ( maps to `<INSTALL_INTERFACE>` ) keywords on commands such as :cmake:command:`rapids_find_package` and :cmake:command:`rapids_cpm_find`.
Lets go over an example on how these come together to make dependency tracking for projects super easy:

.. code-block:: cmake

  rapids_find_package(Threads REQUIRED
    BUILD_EXPORT_SET example-targets
    INSTALL_EXPORT_SET example-targets
    )
  rapids_cpm_find(nlohmann_json 3.9.1
    BUILD_EXPORT_SET example-targets
    )

  add_library(example src.cpp)
  target_link_libraries(example 
    PUBLIC Threads::Threads
      $<BUILD_INTERFACE:nlohmann_json::nlohmann_json>
    )
  install(TARGETS example
    DESTINATION lib
    EXPORT example-targets
    )                 

  set(doc_string [=[Provide targets for the example library.]=])
  rapids_export(INSTALL example
    EXPORT_SET example-targets
    NAMESPACE example::
    DOCUMENTATION doc_string
    )
  rapids_export(BUILD example
    EXPORT_SET example-targets
    NAMESPACE example::
    DOCUMENTATION doc_string
    )


Tracking find_package
*********************

The :cmake:command:`rapids_find_package(<PackageName>)` combines the :cmake:command:`find_package` command and dependency tracking.
In this example we are recording that the `Threads` package is required by both the export set `example-targets` for both the install and build configuration.

What this means is that when :cmake:command:`rapids_export(` is called a the `example-config.cmake` file is generated it will include the call 
`find_dependency(Threads)`, removing the need for developers to mantain that dual source of truth.

The :cmake:command:`rapids_find_package(<PackageName>)` command also supports non-required finds correctly. In those cases `rapids-cmake` only records
the dependency when the underlying :cmake:command:`find_package` command is successful.

It is common for projects to depend on dependencies that CMake doesn't have `Find<Package>` for. In those cases projects will have a custom
`Find<Package>` that they need to use, and install for consumers. Rapids-cmake tries to help projects simplify this process with the commands
:cmake:command:`rapids_find_generate_module` and :cmake:command:`rapids_export_package`.

The :cmake:command:`rapids_find_generate_module` allows for projects to automatically generate a `Find<Package>` and encode via the `BUILD_EXPORT_SET`
and `INSTALL_EXPORT_SET` commands when the generated module should also be installed and part of `CMAKE_MODULE_PATH` so that consumers can use it.

If you already have an existing `Find<Package>` written, :cmake:command:`rapids_export_package` simplify the process of installling the module and 
making sure it is part of `CMAKE_MODULE_PATH` for consumers.

Tracking cpm
************

The :cmake:command:`rapids_cpm_find(<PackageName> <Version>)` combines the :cmake:command:`CPMFindPackage` command and dependency tracking, in a very simillar way
to :cmake:command:`rapids_find_package(<PackageName>)`. In this example what we are saying is that nlohmann_json is only needed by the build directory `example-config`
and not needed by the installed `example-config`. This pattern while rare, does happen when projects have some dependencies that aren't needed by consumers but are
propagate through the usage requirements inside a project via $<BUILD_INTERFACE>. Now you might be asking, but why use a build directory `config` file at all? The most common 
reason is that a developer needs to work on multiple projects using a fast feedback loop, in those cases this workflow avoids having to re-install the project each time 
a change needs to be tested by a consuming project.

Back to :cmake:command:`rapids_cpm_find`. When used with `BUILD_EXPORT_SET` it will generate a :cmake:command:`CPMFindPackage(<PackageName> ...)` call, and when used 
with `INSTALL_EXPORT_SET` it will generate a :cmake:command:`find_dependency(<PackageName> ...)`  call. The theory behind this is that most packages currently don't have
great build `config.cmake` support so it is best to have a fallback to cpm, while it is expected that all CMake packages to have install rules. 
If this isn't the case for a CPM package you can instead use :cmake:command:`rapids_export_cpm`, and :cmake:command:`rapids_export_package` to specify the correct generated commands 
and forgo using `[BUILD|INSTALL]_EXPORT_SET`.


Generating example-config.cmake
*******************************


Before rapids-cmake if a project wanted to generate a config module they would follow the example in 
the `cmake-packages docs https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#creating-packages`_ and use :cmake:command:`install(EXPORT`, 
:cmake:command:`export(EXPORT`, :cmake:command:`write_basic_package_version_file`, and a custom `config.cmake.in` file.

The goal of :cmake:command:`rapids_export` is to replace all the boilerplate with an easy to use function that also embeds the necessary
dependency calls collected by `BUILD_EXPORT_SET` and `INSTALL_EXPORT_SET`. 

:cmake:command:`rapids_export` uses CMake best practises to generate all the necessary components of a project config file. It handles generating
a correct version file, finding dependencies and all the other boilerplate necessary to make well behaved CMake config files. On top of this 
the :cmake:command:`rapids_export` generated files are completly standalone with no dependency on `rapids-cmake`.
 