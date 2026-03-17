include(FetchContent)

# Done as a function so that updates to variables like
# CMAKE_CXX_FLAGS don't propagate out to other
# targets
function(myproject_setup_dependencies)

  # For each dependency, see if it's
  # already been provided to us by a parent project.
  #
  # Dependencies are resolved via find_package(). The Conan CMake
  # provider transparently intercepts these calls and runs
  # conan install using the project's conanfile.py.

  if(NOT TARGET fmt::fmt)
    find_package(fmt REQUIRED)
  endif()

  if(NOT TARGET spdlog::spdlog)
    find_package(spdlog REQUIRED)
  endif()

  if(NOT TARGET Catch2::Catch2WithMain)
    find_package(Catch2 REQUIRED)
    # Conan's CMakeDeps provides targets but does not expose Catch2's test
    # discovery module (Catch.cmake). Locate it in the installed package
    # and add it to CMAKE_MODULE_PATH so include(Catch) works in tests.
    foreach(_dir IN LISTS Catch2_INCLUDE_DIRS)
      cmake_path(GET _dir PARENT_PATH _catch2_root)
      if(EXISTS "${_catch2_root}/lib/cmake/Catch2/Catch.cmake")
        set(CMAKE_MODULE_PATH
          "${_catch2_root}/lib/cmake/Catch2" ${CMAKE_MODULE_PATH} PARENT_SCOPE)
        break()
      endif()
    endforeach()
  endif()

  if(NOT TARGET CLI11::CLI11)
    find_package(CLI11 REQUIRED)
  endif()

  if(NOT TARGET ftxui::screen)
    find_package(ftxui REQUIRED)
  endif()

  # lefticus/tools is not available on Conan, fetch from GitHub.
  # It uses CPM internally to fetch its own dependencies (e.g. fmt).
  # CPM_USE_LOCAL_PACKAGES tells CPM to use find_package() first,
  # so it picks up packages already provided by Conan instead of
  # downloading duplicates.
  if(NOT TARGET lefticus::tools)
    set(CPM_USE_LOCAL_PACKAGES ON)
    FetchContent_Declare(
      tools
      GIT_REPOSITORY https://github.com/lefticus/tools.git
      GIT_TAG main
      GIT_SHALLOW TRUE)
    FetchContent_MakeAvailable(tools)
  endif()

endfunction()
