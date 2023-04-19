macro(set_standards)

  # if the default CMAKE_CXX_STANDARD is not set, detect the latest CXX standard supported by the compiler and use it.
  # This is needed for the tools like clang-tidy, cppcheck, etc.
  # Like not having compiler warnings on by default, this fixes another `bad` default for the compilers
  # Ideally, the user should set a default CMAKE_CXX_STANDARD for their project.
  if("${CMAKE_CXX_STANDARD}" STREQUAL "")
    if(DEFINED CMAKE_CXX20_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_CXX20_EXTENSION_COMPILE_OPTION)
      set(CXX_LATEST_STANDARD 20)
    elseif(DEFINED CMAKE_CXX17_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_CXX17_EXTENSION_COMPILE_OPTION)
      set(CXX_LATEST_STANDARD 17)
    elseif(DEFINED CMAKE_CXX14_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_CXX14_EXTENSION_COMPILE_OPTION)
      set(CXX_LATEST_STANDARD 14)
    else()
      set(CXX_LATEST_STANDARD 11)
    endif()
    message(
      STATUS
        "The default CMAKE_CXX_STANDARD used by external targets and tools is not set yet. Using the latest supported C++ standard that is ${CXX_LATEST_STANDARD}"
    )
    set(CMAKE_CXX_STANDARD ${CXX_LATEST_STANDARD})
  endif()

  if("{CMAKE_C_STANDARD}" STREQUAL "")
    if(DEFINED CMAKE_C17_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_C17_EXTENSION_COMPILE_OPTION)
      set(C_LATEST_STANDARD 17)
    elseif(DEFINED CMAKE_C11_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_C11_EXTENSION_COMPILE_OPTION)
      set(C_LATEST_STANDARD 11)
    elseif(DEFINED CMAKE_C99_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_C99_EXTENSION_COMPILE_OPTION)
      set(C_LATEST_STANDARD 99)
    else()
      set(C_LATEST_STANDARD 90)
    endif()
    message(
      STATUS
        "The default CMAKE_C_STANDARD used by external targets and tools is not set yet. Using the latest supported C standard that is ${C_LATEST_STANDARD}"
    )
    set(CMAKE_C_STANDARD ${C_LATEST_STANDARD})
  endif()

  # strongly encouraged to enable this globally to avoid conflicts between
  # -Wpedantic being enabled and -std=c++xx and -std=gnu++xx when compiling with PCH enabled
  if("${CMAKE_CXX_EXTENSIONS}" STREQUAL "")
    set(CMAKE_CXX_EXTENSIONS OFF)
  endif()

  if("${CMAKE_C_EXTENSIONS}" STREQUAL "")
    set(CMAKE_C_EXTENSIONS OFF)
  endif()

endmacro()
