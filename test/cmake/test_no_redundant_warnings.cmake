# Test that CLANG_WARNINGS does not contain -Wsign-conversion,
# since -Wconversion already implies it for both GCC and Clang.

file(STRINGS "${PROJECT_ROOT}/cmake/CompilerWarnings.cmake" lines)

set(in_clang_block FALSE)
set(found_sign_conversion FALSE)

foreach(line IN LISTS lines)
  if(line MATCHES "set\\(CLANG_WARNINGS")
    set(in_clang_block TRUE)
  endif()

  if(in_clang_block AND line MATCHES "-Wsign-conversion")
    set(found_sign_conversion TRUE)
  endif()

  # The closing paren of the set() ends the block
  if(in_clang_block AND line MATCHES "^[ \t]*\\)[ \t]*$")
    break()
  endif()
endforeach()

if(NOT in_clang_block)
  message(FATAL_ERROR "Could not find CLANG_WARNINGS block in CompilerWarnings.cmake")
endif()

if(found_sign_conversion)
  message(FATAL_ERROR
    "-Wsign-conversion is redundant in CLANG_WARNINGS: "
    "-Wconversion already implies -Wsign-conversion for both GCC and Clang")
endif()

message(STATUS "PASS: No redundant -Wsign-conversion in CLANG_WARNINGS")
