function(myproject_enable_coverage project_name)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    # GCC's --coverage flag doesn't work on macOS ARM (Apple linker
    # can't find libgcov). Skip coverage for GCC on Apple platforms.
    if(APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      message(WARNING "Coverage disabled: GCC --coverage is not supported on macOS ARM")
      return()
    endif()
    target_compile_options(${project_name} INTERFACE --coverage -g)
    target_link_libraries(${project_name} INTERFACE --coverage)
  endif()
endfunction()
