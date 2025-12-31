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

    # Use custom HTML shell if it exists
    set(SHELL_FILE "${CMAKE_SOURCE_DIR}/web/shell.html")
    if(EXISTS "${SHELL_FILE}")
      target_link_options(${target} PRIVATE
        "--shell-file=${SHELL_FILE}"
      )
      # Add shell file as a link dependency so changes trigger rebuild
      set_property(TARGET ${target} APPEND PROPERTY LINK_DEPENDS "${SHELL_FILE}")
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
