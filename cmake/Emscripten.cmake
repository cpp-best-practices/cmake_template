# cmake/Emscripten.cmake
# Emscripten/WebAssembly build configuration

# Detect if we're building with Emscripten
if(EMSCRIPTEN)
  message(STATUS "Emscripten build detected - configuring for WebAssembly")

  # Set WASM build flag
  set(MYPROJECT_WASM_BUILD ON CACHE BOOL "Building for WebAssembly" FORCE)

  # Sanitizers don't work with Emscripten
  set(myproject_ENABLE_SANITIZER_ADDRESS OFF CACHE BOOL "Not supported with Emscripten")
  set(myproject_ENABLE_SANITIZER_LEAK OFF CACHE BOOL "Not supported with Emscripten")
  set(myproject_ENABLE_SANITIZER_UNDEFINED OFF CACHE BOOL "Not supported with Emscripten")
  set(myproject_ENABLE_SANITIZER_THREAD OFF CACHE BOOL "Not supported with Emscripten")
  set(myproject_ENABLE_SANITIZER_MEMORY OFF CACHE BOOL "Not supported with Emscripten")

  # Disable static analysis and strict warnings for Emscripten builds
  set(myproject_ENABLE_CLANG_TIDY OFF CACHE BOOL "Disabled for Emscripten")
  set(myproject_ENABLE_CPPCHECK OFF CACHE BOOL "Disabled for Emscripten")
  set(myproject_WARNINGS_AS_ERRORS OFF CACHE BOOL "Disabled for Emscripten")

  # Disable testing - no way to execute WASM test targets
  set(BUILD_TESTING OFF CACHE BOOL "No test runner for WASM")

  # Resource embedding path (optional)
  set(INTRO_RESOURCES_DIR "" CACHE PATH "Resources directory (optional)")

  # For Emscripten WASM builds, FTXUI requires pthreads
  # Set these flags early so they propagate to all dependencies

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread")

  # Enable native WebAssembly exception handling
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fwasm-exceptions")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fwasm-exceptions")


else()
  set(MYPROJECT_WASM_BUILD OFF CACHE BOOL "Building for WebAssembly" FORCE)
endif()

# Function to apply WASM settings to a target
function(myproject_configure_wasm_target target)
  if(EMSCRIPTEN)
    # Parse optional named arguments
    set(options "")
    set(oneValueArgs TITLE DESCRIPTION)
    set(multiValueArgs "")
    cmake_parse_arguments(WASM "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Set defaults if not provided
    if(NOT WASM_TITLE)
      set(WASM_TITLE "${target}")
    endif()

    if(NOT WASM_DESCRIPTION)
      set(WASM_DESCRIPTION "WebAssembly application")
    endif()

    target_compile_definitions(${target} PRIVATE MYPROJECT_WASM_BUILD=1)

    # Emscripten link flags
    target_link_options(${target} PRIVATE
      # Enable pthreads - REQUIRED by FTXUI's WASM implementation
      "-sUSE_PTHREADS=1"
      "-sPROXY_TO_PTHREAD=1"
      "-sPTHREAD_POOL_SIZE=4"
      # Enable asyncify for emscripten_sleep and async operations
      "-sASYNCIFY=1"
      "-sASYNCIFY_STACK_SIZE=65536"
      # Memory configuration
      "-sALLOW_MEMORY_GROWTH=1"
      "-sINITIAL_MEMORY=33554432"
      # Environment - need both web and worker for pthread support
      "-sENVIRONMENT=web,worker"
      # Export runtime methods for JavaScript interop
      "-sEXPORTED_RUNTIME_METHODS=['FS','ccall','cwrap','UTF8ToString','stringToUTF8','lengthBytesUTF8']"
      # Export malloc/free for MAIN_THREAD_EM_ASM usage
      "-sEXPORTED_FUNCTIONS=['_main','_malloc','_free']"
      # Enable native WebAssembly exception handling
      "-fwasm-exceptions"
      # Debug: enable assertions for better error messages
      "-sASSERTIONS=1"
    )

    # Embed resources into WASM binary (optional)
    if(INTRO_RESOURCES_DIR AND EXISTS "${INTRO_RESOURCES_DIR}")
      target_link_options(${target} PRIVATE
        "--embed-file=${INTRO_RESOURCES_DIR}@/resources"
      )
      message(STATUS "Embedding resources from ${INTRO_RESOURCES_DIR}")
    else()
      message(STATUS "No resources directory configured, skipping resource embedding")
    endif()

    # Configure the shell HTML template for this target
    set(TARGET_NAME "${target}")
    set(TARGET_TITLE "${WASM_TITLE}")
    set(TARGET_DESCRIPTION "${WASM_DESCRIPTION}")
    set(AT "@")  # For escaping @ in npm package URLs
    set(TEMPLATE_FILE "${CMAKE_SOURCE_DIR}/web/shell_template.html.in")
    set(CONFIGURED_SHELL "${CMAKE_BINARY_DIR}/web/${target}_shell.html")

    # Create output directory
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/web")

    # Generate target-specific shell file
    if(EXISTS "${TEMPLATE_FILE}")
      configure_file(
        "${TEMPLATE_FILE}"
        "${CONFIGURED_SHELL}"
        @ONLY
      )

      # Use the generated shell file
      target_link_options(${target} PRIVATE
        "--shell-file=${CONFIGURED_SHELL}"
      )

      # Add both template and configured file as link dependencies
      set_property(TARGET ${target} APPEND PROPERTY LINK_DEPENDS
        "${TEMPLATE_FILE}"
        "${CONFIGURED_SHELL}"
      )

      message(STATUS "Configured WASM shell for ${target}: ${CONFIGURED_SHELL}")
    else()
      message(WARNING "Shell template not found: ${TEMPLATE_FILE}")
    endif()

    # Copy service worker for COOP/COEP headers (needed for GitHub Pages)
    set(COI_WORKER "${CMAKE_SOURCE_DIR}/web/coi-serviceworker.min.js")
    if(EXISTS "${COI_WORKER}")
      add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
          "${COI_WORKER}"
          "$<TARGET_FILE_DIR:${target}>/coi-serviceworker.min.js"
        COMMENT "Copying coi-serviceworker.min.js for COOP/COEP headers"
      )
    endif()

    # Set output suffix to .html
    set_target_properties(${target} PROPERTIES SUFFIX ".html")

    message(STATUS "Configured ${target} for WebAssembly")
  endif()
endfunction()
