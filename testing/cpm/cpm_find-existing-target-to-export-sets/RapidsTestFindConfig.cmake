#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
@PACKAGE_INIT@

include("${CMAKE_CURRENT_LIST_DIR}/RapidsTestFindConfigVersion.cmake")

add_library(RapidsTest::RapidsTest IMPORTED INTERFACE GLOBAL)

check_required_components(RapidsTest2)
