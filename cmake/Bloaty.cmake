# Bloaty McBloatface - Binary size analyzer
# Creates custom targets for analyzing executable and library sizes.
# Usage: myproject_setup_bloaty(<target_name>)
# Creates targets: bloaty_<target> (sections), bloaty_<target>_full (compile units + symbols)

function(myproject_setup_bloaty TARGET_NAME)
  find_program(BLOATY bloaty)
  if(BLOATY)
    # Sections breakdown (always available, no debug info needed)
    add_custom_target(
      bloaty_${TARGET_NAME}
      COMMAND ${BLOATY} $<TARGET_FILE:${TARGET_NAME}> -d sections --domain=vm
      DEPENDS ${TARGET_NAME}
      COMMENT "Running Bloaty size analysis on ${TARGET_NAME}..."
      VERBATIM
    )

    # Compile-unit and symbol breakdown (requires debug info)
    add_custom_target(
      bloaty_${TARGET_NAME}_full
      COMMAND ${BLOATY} $<TARGET_FILE:${TARGET_NAME}> -d compileunits,symbols --domain=vm -n 30
      DEPENDS ${TARGET_NAME}
      COMMENT "Running detailed Bloaty analysis on ${TARGET_NAME} (requires debug info)..."
      VERBATIM
    )

    message(STATUS "Bloaty McBloatface targets created for ${TARGET_NAME}")
  else()
    message(${myproject_WARNING_TYPE} "Bloaty requested but not found. Install from https://github.com/google/bloaty")
  endif()
endfunction()
