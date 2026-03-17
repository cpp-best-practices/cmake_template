# Lizard - Code complexity analyzer
# Creates custom targets for analyzing cyclomatic complexity.
# Targets: lizard (warnings), lizard_html (HTML report), lizard_xml (XML report)

function(myproject_setup_lizard WARNINGS_AS_ERRORS)
  find_program(LIZARD lizard)
  if(LIZARD)
    set(LIZARD_CCN_THRESHOLD 15 CACHE STRING "Cyclomatic complexity threshold")
    set(LIZARD_LENGTH_THRESHOLD 100 CACHE STRING "Function length threshold (lines)")
    set(LIZARD_PARAM_THRESHOLD 6 CACHE STRING "Parameter count threshold")

    set(LIZARD_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/include" "${CMAKE_SOURCE_DIR}/src")

    set(LIZARD_COMMON_ARGS
        -C ${LIZARD_CCN_THRESHOLD}
        -L ${LIZARD_LENGTH_THRESHOLD}
        -a ${LIZARD_PARAM_THRESHOLD}
        -Eduplicate
        -x "*/build/*"
        -x "*/test/*"
        -x "*/fuzz_test/*"
        -x "*/_deps/*"
        -t 4
        ${LIZARD_INCLUDE_DIRS}
    )

    # When warnings are errors, fail the build on any lizard warning
    set(LIZARD_ERROR_ARGS)
    if(${WARNINGS_AS_ERRORS})
      message(STATUS "Lizard: Warnings will be treated as errors")
      list(APPEND LIZARD_ERROR_ARGS -i 0)
    endif()

    add_custom_target(
      lizard
      COMMAND ${LIZARD}
              ${LIZARD_COMMON_ARGS}
              --warnings_only
              ${LIZARD_ERROR_ARGS}
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Running Lizard complexity analyzer..."
      VERBATIM
    )

    add_custom_target(
      lizard_html
      COMMAND ${LIZARD}
              ${LIZARD_COMMON_ARGS}
              -H
              -o "${CMAKE_BINARY_DIR}/lizard_report.html"
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Generating Lizard HTML report..."
      VERBATIM
    )

    add_custom_target(
      lizard_xml
      COMMAND ${LIZARD}
              ${LIZARD_COMMON_ARGS}
              -X
              -o "${CMAKE_BINARY_DIR}/lizard_report.xml"
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Generating Lizard XML report for CI..."
      VERBATIM
    )

    message(STATUS "Lizard enabled (CCN: ${LIZARD_CCN_THRESHOLD}, Length: ${LIZARD_LENGTH_THRESHOLD}, Params: ${LIZARD_PARAM_THRESHOLD})")
  else()
    message(${myproject_WARNING_TYPE} "Lizard requested but not found. Install with: pip install lizard")
  endif()
endfunction()
