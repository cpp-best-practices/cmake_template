# Conan 2.0 CMake Provider Integration
#
# Downloads the cmake-conan provider on-demand to the build directory
# and registers it as a top-level include so that find_package() calls
# are transparently satisfied by Conan during the project() call.
#
# This file must be included BEFORE the project() call.

set(CONAN_PROVIDER_LOCATION "${CMAKE_BINARY_DIR}/cmake/conan_provider.cmake")

if(NOT EXISTS "${CONAN_PROVIDER_LOCATION}")
  message(STATUS "Downloading Conan CMake provider...")
  file(DOWNLOAD
    "https://raw.githubusercontent.com/conan-io/cmake-conan/develop2/conan_provider.cmake"
    "${CONAN_PROVIDER_LOCATION}"
    STATUS _download_status)
  list(GET _download_status 0 _download_code)
  if(NOT _download_code EQUAL 0)
    list(GET _download_status 1 _download_msg)
    message(FATAL_ERROR
      "Failed to download Conan CMake provider: ${_download_msg}\n"
      "Ensure you have internet access.")
  endif()
endif()

list(APPEND CMAKE_PROJECT_TOP_LEVEL_INCLUDES "${CONAN_PROVIDER_LOCATION}")

# Conan requires a build type to be set before project().
# StandardProjectSettings.cmake also defaults to RelWithDebInfo, but it runs
# after myproject_setup_dependencies() — too late for the Conan provider which
# needs the build type during find_package() calls.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")
  set(CMAKE_BUILD_TYPE
    RelWithDebInfo
    CACHE STRING "Choose the type of build." FORCE)
  set_property(
    CACHE CMAKE_BUILD_TYPE
    PROPERTY STRINGS
      "Debug"
      "Release"
      "MinSizeRel"
      "RelWithDebInfo")
endif()
