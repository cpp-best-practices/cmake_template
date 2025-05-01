# Bloaty McBloatface - A binary size analyzer
# This module enables Bloaty for analyzing executable and library sizes

function(myproject_setup_bloaty TARGET_NAME)
  find_program(BLOATY bloaty)
  if(BLOATY)
    # Define output directory
    set(BLOATY_OUTPUT_DIR "${CMAKE_BINARY_DIR}/bloaty_reports")
    file(MAKE_DIRECTORY ${BLOATY_OUTPUT_DIR})
    
    # Default report sections
    set(BLOATY_SECTIONS "sections,symbols,compileunits")
    
    # Create custom target for basic size analysis
    add_custom_target(
      bloaty_${TARGET_NAME}
      COMMAND ${BLOATY} $<TARGET_FILE:${TARGET_NAME}> -d ${BLOATY_SECTIONS} --domain=vm
      DEPENDS ${TARGET_NAME}
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Running Bloaty size analysis on ${TARGET_NAME}..."
    )
    
    # Create custom target for CSV report
    add_custom_target(
      bloaty_${TARGET_NAME}_csv
      COMMAND ${BLOATY} $<TARGET_FILE:${TARGET_NAME}> -d ${BLOATY_SECTIONS} --csv > "${BLOATY_OUTPUT_DIR}/${TARGET_NAME}_size.csv"
      DEPENDS ${TARGET_NAME}
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Generating Bloaty CSV report for ${TARGET_NAME}..."
    )
    
    # Create custom target for diff against a baseline
    # This target needs to be manually called with a baseline file
    add_custom_target(
      bloaty_${TARGET_NAME}_diff
      COMMAND ${CMAKE_COMMAND} -E echo "Run with: cmake --build build --target bloaty_${TARGET_NAME}_diff -- --baseline=/path/to/baseline"
      COMMENT "To compare against a baseline, provide --baseline argument"
    )

    # Add custom command to track binary size changes over time
    add_custom_target(
      bloaty_${TARGET_NAME}_store
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${TARGET_NAME}> "${BLOATY_OUTPUT_DIR}/${TARGET_NAME}_baseline_$$(date +%Y%m%d%H%M%S)"
      COMMAND ${CMAKE_COMMAND} -E echo "Stored baseline at ${BLOATY_OUTPUT_DIR}/${TARGET_NAME}_baseline_$$(date +%Y%m%d%H%M%S)"
      DEPENDS ${TARGET_NAME}
      COMMENT "Storing current binary as baseline for ${TARGET_NAME}..."
    )
    
    # Create custom target for template analysis (C++ specific)
    add_custom_target(
      bloaty_${TARGET_NAME}_templates
      COMMAND ${BLOATY} $<TARGET_FILE:${TARGET_NAME}> -d template_params,symbols
      DEPENDS ${TARGET_NAME}
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Analyzing template usage in ${TARGET_NAME}..."
    )
    
    message(STATUS "Bloaty McBloatface targets created for ${TARGET_NAME}")
  else()
    message(${myproject_WARNING_TYPE} "Bloaty McBloatface requested but executable not found. Install with 'apt install bloaty' or from https://github.com/google/bloaty")
  endif()
endfunction()

# Function to add bloaty analysis to all executable targets
function(myproject_enable_bloaty)
  find_program(BLOATY bloaty)
  if(BLOATY)
    # Get all executable targets
    get_all_executable_targets(ALL_TARGETS)
    
    # Create global target that will depend on all individual targets
    add_custom_target(bloaty_all)
    
    # Create individual bloaty targets for each executable
    foreach(TARGET_NAME ${ALL_TARGETS})
      myproject_setup_bloaty(${TARGET_NAME})
      add_dependencies(bloaty_all bloaty_${TARGET_NAME})
    endforeach()
    
    message(STATUS "Bloaty McBloatface enabled for all executable targets")
  else()
    message(${myproject_WARNING_TYPE} "Bloaty McBloatface requested but executable not found. Install with 'apt install bloaty' or from https://github.com/google/bloaty")
  endif()
endfunction()

# Helper function to get all executable targets
function(get_all_executable_targets RESULT)
  set(TARGETS)
  
  # Recursive function to get all targets
  get_property(TARGETS_IN_DIR DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" PROPERTY BUILDSYSTEM_TARGETS)
  
  foreach(TARGET_NAME ${TARGETS_IN_DIR})
    get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)
    if(TARGET_TYPE STREQUAL "EXECUTABLE")
      list(APPEND TARGETS ${TARGET_NAME})
    endif()
  endforeach()
  
  # Check subdirectories
  get_property(SUBDIRS DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" PROPERTY SUBDIRECTORIES)
  foreach(SUBDIR ${SUBDIRS})
    get_all_executable_targets_in_dir(${SUBDIR} SUBDIR_TARGETS)
    list(APPEND TARGETS ${SUBDIR_TARGETS})
  endforeach()
  
  set(${RESULT} ${TARGETS} PARENT_SCOPE)
endfunction()

# Helper function to get targets in a specific directory
function(get_all_executable_targets_in_dir DIR RESULT)
  set(TARGETS)
  
  get_property(TARGETS_IN_DIR DIRECTORY "${DIR}" PROPERTY BUILDSYSTEM_TARGETS)
  
  foreach(TARGET_NAME ${TARGETS_IN_DIR})
    get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)
    if(TARGET_TYPE STREQUAL "EXECUTABLE")
      list(APPEND TARGETS ${TARGET_NAME})
    endif()
  endforeach()
  
  # Check subdirectories
  get_property(SUBDIRS DIRECTORY "${DIR}" PROPERTY SUBDIRECTORIES)
  foreach(SUBDIR ${SUBDIRS})
    get_all_executable_targets_in_dir(${SUBDIR} SUBDIR_TARGETS)
    list(APPEND TARGETS ${SUBDIR_TARGETS})
  endforeach()
  
  set(${RESULT} ${TARGETS} PARENT_SCOPE)
endfunction()