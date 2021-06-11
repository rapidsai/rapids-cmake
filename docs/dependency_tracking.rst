
Dependency Tracking
###################

One of the biggest features of rapids-cmake is that is can track dependencies ( `find_package`, `cpm` )
allowing for projects to easily generate `<project>-config.cmake` files with correct dependency requirements.
In a normal CMake project public dependencies need to be recorded in two locations, the original ``CMakeLists.txt`` file and also the generated `<project>-config.cmake`. This dual source of truth increases
developer burden, and adds a common source of error.

``rapids-cmake`` is designed to remove this dual source of truth by encoding

Lets go over an example

Recording find_package
**********************


Recording cpm_packs
*******************


Exporting
*********
