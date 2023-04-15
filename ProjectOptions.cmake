option(myproject_ENABLE_IPO "Enable IPO/LTO" ON)
option(myproject_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
option(myproject_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
option(myproject_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ON)
option(myproject_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
option(myproject_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ON)
option(myproject_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
option(myproject_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
option(myproject_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
option(myproject_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
option(myproject_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
option(myproject_ENABLE_PCH "Enable precompiled headers" OFF)
option(myproject_ENABLE_CACHE "Enable ccache" ON)


include(cmake/InterproceduralOptimization.cmake)
if(myproject_ENABLE_IPO)
  enable_ipo()
endif()

### set up project options

include(cmake/StandardProjectSettings.cmake)

add_library(myproject_warnings INTERFACE)
add_library(myproject_options INTERFACE)

include(cmake/CompilerWarnings.cmake)
set_project_warnings(
  myproject_warnings
  ${myproject_WARNINGS_AS_ERRORS}
  "" 
  ""
  ""
  "")

include(cmake/Linker.cmake)
if(myproject_ENABLE_USER_LINKER)
  configure_linker(myproject_options)
endif()

include(cmake/Sanitizers.cmake)
enable_sanitizers(
  myproject_options
  ${myproject_ENABLE_SANITIZER_ADDRESS}
  ${myproject_ENABLE_SANITIZER_LEAK}
  ${myproject_ENABLE_SANITIZER_UNDEFINED}
  ${myproject_ENABLE_SANITIZER_THREAD}
  ${myproject_ENABLE_SANITIZER_MEMORY})

set_target_properties(myproject_options PROPERTIES UNITY_BUILD ${myproject_ENABLE_UNITY_BUILD})


if(myproject_ENABLE_PCH)
  target_precompile_headers(
    myproject_options
    INTERFACE
    <vector>
    <string>
    <utility>)
endif()

if (myproject_ENABLE_CACHE)
  include(cmake/Cache.cmake)
  enable_cache()
endif()

include(cmake/StaticAnalyzers.cmake)
if(myproject_ENABLE_CLANG_TIDY)
  enable_clang_tidy(myproject_options ${myproject_WARNINGS_AS_ERRORS})
endif()

if(myproject_ENABLE_CPPCHECK)
  enable_cppcheck(${myproject_WARNINGS_AS_ERRORS}
    "" # override cppcheck options
    )
endif()


