# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

execute_process(COMMAND ${TEST_COMMAND} RESULT_VARIABLE result OUTPUT_VARIABLE stdout
                ERROR_VARIABLE stderr)

if(NOT WILL_FAIL AND NOT result EQUAL 0)
  string(REPLACE "\n" "\n  " formatted_stdout "${stdout}")
  string(REPLACE "\n" "\n  " formatted_stderr "${stderr}")
  message(SEND_ERROR "Expected exit code 0, got ${result}\nActual stdout:\n  ${formatted_stdout}\nActual stderr:\n  ${formatted_stderr}"
  )
endif()

if(EXPECTED_REGULAR_EXPRESSION AND NOT stdout MATCHES "${EXPECTED_REGULAR_EXPRESSION}"
   AND NOT stderr MATCHES "${EXPECTED_REGULAR_EXPRESSION}")
  string(REPLACE "\n" "\n  " formatted_expected_regular_expression "${EXPECTED_REGULAR_EXPRESSION}")
  string(REPLACE "\n" "\n  " formatted_stdout "${stdout}")
  string(REPLACE "\n" "\n  " formatted_stderr "${stderr}")
  message(SEND_ERROR "Expected regular expression:\n  ${formatted_expected_regular_expression}\nActual stdout:\n  ${formatted_stdout}\nActual stderr:\n  ${formatted_stderr}"
  )
endif()

if(NOT WILL_FAIL AND (stdout MATCHES "Syntax Warning" OR stderr MATCHES "Syntax Warning"))
  message(SEND_ERROR "Got a syntax warning")
endif()
