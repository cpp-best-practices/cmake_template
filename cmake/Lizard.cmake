# Lizard - A cyclomatic complexity analyzer
# This module enables Lizard for analyzing code complexity

function(myproject_setup_lizard WARNINGS_AS_ERRORS)
  find_program(LIZARD lizard)
  if(LIZARD)
    # Define thresholds
    set(LIZARD_CCN_THRESHOLD 15 CACHE STRING "Threshold for cyclomatic complexity")
    set(LIZARD_LENGTH_THRESHOLD 100 CACHE STRING "Threshold for function length in lines")
    set(LIZARD_PARAM_THRESHOLD 6 CACHE STRING "Threshold for number of parameters")
    set(LIZARD_WARNINGS_THRESHOLD 0 CACHE STRING "Threshold for number of warnings before causing error exit")
    
    # Define target directories
    set(LIZARD_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/include" "${CMAKE_SOURCE_DIR}/src")
    
    # Define common arguments
    set(LIZARD_COMMON_ARGS
        -C ${LIZARD_CCN_THRESHOLD}
        -L ${LIZARD_LENGTH_THRESHOLD}
        -a ${LIZARD_PARAM_THRESHOLD}
        -Eduplicate
        -x "*/build/*"
        -x "*/test/*"
        -x "*/fuzz_test/*"
        -x "*/out/*"
        -x "*/_deps/*"
        -t 4
        ${LIZARD_INCLUDE_DIRS}
    )
    
    # Add warning as error settings if enabled
    if(${WARNINGS_AS_ERRORS})
      message(STATUS "Lizard: Warnings will be treated as errors")
      set(LIZARD_WARNINGS_THRESHOLD 0)
    endif()
    
    # Create a custom target for warnings-only mode
    add_custom_target(
      lizard
      COMMAND ${LIZARD}
              ${LIZARD_COMMON_ARGS}
              --warnings_only
              -i ${LIZARD_WARNINGS_THRESHOLD}
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Running Lizard complexity analyzer..."
    )
    
    # Create HTML report target
    add_custom_target(
      lizard_html
      COMMAND ${LIZARD}
              ${LIZARD_COMMON_ARGS}
              -H
              -o "${CMAKE_BINARY_DIR}/lizard_report.html"
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Generating Lizard HTML report..."
    )
    
    # Create XML report target for CI integration
    add_custom_target(
      lizard_xml
      COMMAND ${LIZARD}
              ${LIZARD_COMMON_ARGS}
              -X
              -o "${CMAKE_BINARY_DIR}/lizard_report.xml"
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Generating Lizard XML report for CI..."
    )
    
    message(STATUS "Lizard complexity analyzer enabled with thresholds: \
      \n  CCN: ${LIZARD_CCN_THRESHOLD} \
      \n  Function Length: ${LIZARD_LENGTH_THRESHOLD} \
      \n  Parameter Count: ${LIZARD_PARAM_THRESHOLD} \
      \n  Warnings Threshold: ${LIZARD_WARNINGS_THRESHOLD}")
  else()
    message(${myproject_WARNING_TYPE} "Lizard requested but executable not found. Install with 'pip install lizard'")
  endif()
endfunction()
