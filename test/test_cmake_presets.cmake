# Regression test for issue #139.
#
# CMakePresets.json must disable cppcheck and clang-tidy on the windows-clang
# preset using the project's actual option names, otherwise from-scratch builds
# fail when WARNINGS_AS_ERRORS is on and cppcheck flags third-party headers.

if(NOT DEFINED PRESETS_FILE)
  message(FATAL_ERROR "PRESETS_FILE not defined")
endif()

file(READ "${PRESETS_FILE}" PRESETS_JSON)

string(JSON CONFIGURE_PRESETS_LEN LENGTH "${PRESETS_JSON}" "configurePresets")
math(EXPR LAST_PRESET_IDX "${CONFIGURE_PRESETS_LEN} - 1")

set(WINDOWS_PRESET_INDEX -1)
foreach(I RANGE 0 ${LAST_PRESET_IDX})
  string(JSON NAME GET "${PRESETS_JSON}" "configurePresets" ${I} "name")
  if(NAME STREQUAL "conf-windows-common")
    set(WINDOWS_PRESET_INDEX ${I})
    break()
  endif()
endforeach()

if(WINDOWS_PRESET_INDEX EQUAL -1)
  message(FATAL_ERROR "conf-windows-common preset not found in ${PRESETS_FILE}")
endif()

string(JSON CACHE_VARS GET "${PRESETS_JSON}"
  "configurePresets" ${WINDOWS_PRESET_INDEX} "cacheVariables")

function(_assert_disabled var_name)
  string(JSON VAL ERROR_VARIABLE ERR GET "${CACHE_VARS}" "${var_name}")
  if(ERR)
    message(FATAL_ERROR
      "conf-windows-common cacheVariables is missing ${var_name}; "
      "expected it to disable the analyzer (issue #139). "
      "JSON error: ${ERR}")
  endif()
  if(NOT (VAL STREQUAL "OFF" OR VAL STREQUAL "FALSE" OR VAL STREQUAL "0" OR VAL STREQUAL "NO"))
    message(FATAL_ERROR
      "conf-windows-common cacheVariables sets ${var_name}=${VAL}, expected OFF/FALSE")
  endif()
endfunction()

_assert_disabled("myproject_ENABLE_CPPCHECK")
_assert_disabled("myproject_ENABLE_CLANG_TIDY")

message(STATUS "conf-windows-common correctly disables cppcheck and clang-tidy")
