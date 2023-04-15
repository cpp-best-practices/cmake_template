cmake_minimum_required(VERSION 3.16)

set(ProjectOptions_SRC_DIR
    ${CMAKE_CURRENT_LIST_DIR}
    CACHE FILEPATH "")

include("${ProjectOptions_SRC_DIR}/PreventInSourceBuilds.cmake")

include("${ProjectOptions_SRC_DIR}/Vcpkg.cmake")

include("${ProjectOptions_SRC_DIR}/SystemLink.cmake")

include("${ProjectOptions_SRC_DIR}/Cuda.cmake")

include("${ProjectOptions_SRC_DIR}/PackageProject.cmake")

#
# Params:
# - WARNINGS_AS_ERRORS: Treat compiler warnings as errors
# - ENABLE_CPPCHECK: Enable static analysis with cppcheck
# - ENABLE_CLANG_TIDY: Enable static analysis with clang-tidy
# - ENABLE_INCLUDE_WHAT_YOU_USE: Enable static analysis with include-what-you-use
# - ENABLE_COVERAGE: Enable coverage reporting for gcc/clang
# - ENABLE_CACHE: Enable cache if available
# - ENABLE_PCH: Enable Precompiled Headers
# - PCH_HEADERS: the list of the headers to precompile
# - ENABLE_CONAN: Use Conan for dependency management
# - ENABLE_DOXYGEN: Enable doxygen doc builds of source
# - DOXYGEN_THEME: the name of the Doxygen theme to use. Supported themes: `awesome-sidebar` (default), `awesome` and `original`.
# - ENABLE_IPO: Enable Interprocedural Optimization, aka Link Time Optimization (LTO)
# - ENABLE_USER_LINKER: Enable a specific linker if available
# - ENABLE_BUILD_WITH_TIME_TRACE: Enable -ftime-trace to generate time tracing .json files on clang
# - ENABLE_UNITY: Enable Unity builds of projects
# - ENABLE_SANITIZER_ADDRESS: Enable address sanitizer
# - ENABLE_SANITIZER_LEAK: Enable leak sanitizer
# - ENABLE_SANITIZER_UNDEFINED_BEHAVIOR: Enable undefined behavior sanitizer
# - ENABLE_SANITIZER_THREAD: Enable thread sanitizer
# - ENABLE_SANITIZER_MEMORY: Enable memory sanitizer
# - MSVC_WARNINGS: Override the defaults for the MSVC warnings
# - CLANG_WARNINGS: Override the defaults for the CLANG warnings
# - GCC_WARNINGS: Override the defaults for the GCC warnings
# - CUDA_WARNINGS: Override the defaults for the CUDA warnings
# - CPPCHECK_OPTIONS: Override the defaults for CppCheck settings
# - CONAN_OPTIONS: Extra Conan options
#
# NOTE: cmake-lint [C0103] Invalid macro name "project_options" doesn't match `[0-9A-Z_]+`
macro(project_options)
  set(options
      WARNINGS_AS_ERRORS
      ENABLE_COVERAGE
      ENABLE_CPPCHECK
      ENABLE_CLANG_TIDY
      ENABLE_INCLUDE_WHAT_YOU_USE
      ENABLE_CACHE
      ENABLE_PCH
      ENABLE_CONAN
      ENABLE_VCPKG
      ENABLE_DOXYGEN
      ENABLE_IPO
      ENABLE_USER_LINKER
      ENABLE_BUILD_WITH_TIME_TRACE
      ENABLE_UNITY
      ENABLE_SANITIZER_ADDRESS
      ENABLE_SANITIZER_LEAK
      ENABLE_SANITIZER_UNDEFINED_BEHAVIOR
      ENABLE_SANITIZER_THREAD
      ENABLE_SANITIZER_MEMORY)
  set(oneValueArgs DOXYGEN_THEME)
  set(multiValueArgs
      MSVC_WARNINGS
      CLANG_WARNINGS
      GCC_WARNINGS
      CUDA_WARNINGS
      CPPCHECK_OPTIONS
      PCH_HEADERS
      CONAN_OPTIONS)
  cmake_parse_arguments(
    ProjectOptions
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  # set warning message level
  if(${ProjectOptions_WARNINGS_AS_ERRORS})
    set(WARNINGS_AS_ERRORS ${ProjectOptions_WARNINGS_AS_ERRORS})
    set(WARNING_MESSAGE SEND_ERROR)
  else()
    set(WARNING_MESSAGE WARNING)
  endif()

  include("${ProjectOptions_SRC_DIR}/StandardProjectSettings.cmake")

  if(${ProjectOptions_ENABLE_IPO})
    include("${ProjectOptions_SRC_DIR}/InterproceduralOptimization.cmake")
    enable_ipo()
  endif()

  # Link this 'library' to set the c++ standard / compile-time options requested
  add_library(project_options INTERFACE)

  if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    if(ProjectOptions_ENABLE_BUILD_WITH_TIME_TRACE)
      target_compile_options(project_options INTERFACE -ftime-trace)
    endif()
  endif()

  # Link this 'library' to use the warnings specified in CompilerWarnings.cmake
  add_library(project_warnings INTERFACE)

  if(${ProjectOptions_ENABLE_CACHE})
    # enable cache system
    include("${ProjectOptions_SRC_DIR}/Cache.cmake")
    enable_cache()
  endif()

  if(${ProjectOptions_ENABLE_USER_LINKER})
    # Add linker configuration
    include("${ProjectOptions_SRC_DIR}/Linker.cmake")
    configure_linker(project_options)
  endif()

  # standard compiler warnings
  include("${ProjectOptions_SRC_DIR}/CompilerWarnings.cmake")
  set_project_warnings(
    project_warnings
    "${WARNINGS_AS_ERRORS}"
    "${ProjectOptions_MSVC_WARNINGS}"
    "${ProjectOptions_CLANG_WARNINGS}"
    "${ProjectOptions_GCC_WARNINGS}"
    "${ProjectOptions_CUDA_WARNINGS}")

  include("${ProjectOptions_SRC_DIR}/Tests.cmake")
  if(${ProjectOptions_ENABLE_COVERAGE})
    enable_coverage(project_options)
  endif()

  # sanitizer options if supported by compiler
  include("${ProjectOptions_SRC_DIR}/Sanitizers.cmake")
  enable_sanitizers(
    project_options
    ${ProjectOptions_ENABLE_SANITIZER_ADDRESS}
    ${ProjectOptions_ENABLE_SANITIZER_LEAK}
    ${ProjectOptions_ENABLE_SANITIZER_UNDEFINED_BEHAVIOR}
    ${ProjectOptions_ENABLE_SANITIZER_THREAD}
    ${ProjectOptions_ENABLE_SANITIZER_MEMORY})

  if(${ProjectOptions_ENABLE_DOXYGEN})
    # enable doxygen
    include("${ProjectOptions_SRC_DIR}/Doxygen.cmake")
    enable_doxygen("${ProjectOptions_DOXYGEN_THEME}")
  endif()

  # allow for static analysis options
  include("${ProjectOptions_SRC_DIR}/StaticAnalyzers.cmake")
  if(${ProjectOptions_ENABLE_CPPCHECK})
    enable_cppcheck("${ProjectOptions_CPPCHECK_OPTIONS}")
  endif()

  if(${ProjectOptions_ENABLE_CLANG_TIDY})
    enable_clang_tidy()
  endif()

  if(${ProjectOptions_ENABLE_INCLUDE_WHAT_YOU_USE})
    enable_include_what_you_use()
  endif()

  if(${ProjectOptions_ENABLE_PCH})
    if(NOT ProjectOptions_PCH_HEADERS)
      set(ProjectOptions_PCH_HEADERS
          <vector>
          <string>
          <map>
          <utility>)
    endif()
    target_precompile_headers(project_options INTERFACE ${ProjectOptions_PCH_HEADERS})
  endif()

  if(${ProjectOptions_ENABLE_VCPKG})
    include("${ProjectOptions_SRC_DIR}/Vcpkg.cmake")
    run_vcpkg()
  endif()

  if(${ProjectOptions_ENABLE_CONAN})
    include("${ProjectOptions_SRC_DIR}/Conan.cmake")
    run_conan()
  endif()

  if(${ProjectOptions_ENABLE_UNITY})
    # Add for any project you want to apply unity builds for
    set_target_properties(project_options PROPERTIES UNITY_BUILD ON)
  endif()

endmacro()
