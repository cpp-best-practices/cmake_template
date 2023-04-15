include(FetchContent)

macro(run_vcpkg)
  # named boolean ENABLE_VCPKG_UPDATE argument
  set(options ENABLE_VCPKG_UPDATE)
  # optional named VCPKG_DIR and VCPKG_URL argument
  set(oneValueArgs VCPKG_DIR VCPKG_URL)
  cmake_parse_arguments(
    _vcpkg_args
    "${options}"
    "${oneValueArgs}"
    ""
    ${ARGN})

  if(NOT
     "${_vcpkg_args_VCPKG_DIR}"
     STREQUAL
     "")
    # the installation directory is specified
    get_filename_component(VCPKG_PARENT_DIR ${_vcpkg_args_VCPKG_DIR} DIRECTORY)
  else()
    # Default vcpkg installation directory
    if(WIN32)
      set(VCPKG_PARENT_DIR $ENV{userprofile})
      set(_vcpkg_args_VCPKG_DIR ${VCPKG_PARENT_DIR}/vcpkg)
    else()
      set(VCPKG_PARENT_DIR $ENV{HOME})
      set(_vcpkg_args_VCPKG_DIR ${VCPKG_PARENT_DIR}/vcpkg)
    endif()
  endif()

  # check if vcpkg is installed
  if(WIN32 AND "${CMAKE_EXECUTABLE_SUFFIX}" STREQUAL "")
    set(CMAKE_EXECUTABLE_SUFFIX ".exe")
  endif()
  if(EXISTS "${_vcpkg_args_VCPKG_DIR}" AND EXISTS "${_vcpkg_args_VCPKG_DIR}/vcpkg${CMAKE_EXECUTABLE_SUFFIX}")
    message(STATUS "vcpkg is already installed at ${_vcpkg_args_VCPKG_DIR}.")
    if(${_vcpkg_args_ENABLE_VCPKG_UPDATE})
      message(STATUS "Updating the repository...")
      execute_process(COMMAND "git" "pull" WORKING_DIRECTORY ${_vcpkg_args_VCPKG_DIR})
    endif()
  else()
    message(STATUS "Installing vcpkg at ${_vcpkg_args_VCPKG_DIR}")
    # clone vcpkg from Github
    if("${_vcpkg_args_VCPKG_URL}" STREQUAL "")
      set(_vcpkg_args_VCPKG_URL "https://github.com/microsoft/vcpkg.git")
    endif()
    find_program(GIT_EXECUTABLE "git" REQUIRED)
    execute_process(COMMAND "${GIT_EXECUTABLE}" "clone" "${_vcpkg_args_VCPKG_URL}"
                    WORKING_DIRECTORY ${VCPKG_PARENT_DIR} COMMAND_ERROR_IS_FATAL LAST)
    # Run vcpkg bootstrap
    if(WIN32)
      execute_process(COMMAND "bootstrap-vcpkg.bat" "-disableMetrics" WORKING_DIRECTORY "${_vcpkg_args_VCPKG_DIR}"
                                                                                        COMMAND_ERROR_IS_FATAL LAST)
    else()
      execute_process(COMMAND "./bootstrap-vcpkg.sh" "-disableMetrics" WORKING_DIRECTORY "${_vcpkg_args_VCPKG_DIR}"
                                                                                         COMMAND_ERROR_IS_FATAL LAST)
    endif()
  endif()

  # Setting up vcpkg toolchain
  list(APPEND VCPKG_FEATURE_FLAGS "versions")
  set(CMAKE_TOOLCHAIN_FILE
      ${_vcpkg_args_VCPKG_DIR}/scripts/buildsystems/vcpkg.cmake
      CACHE STRING "vcpkg toolchain file")
endmacro()
