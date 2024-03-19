# ! target_link_cuda
# A function that links Cuda to the given target
#
# # Example
# add_executable(main_cuda main.cu)
# target_compile_features(main_cuda PRIVATE cxx_std_17)
# target_link_libraries(main_cuda PRIVATE project_options project_warnings)
# target_link_cuda(main_cuda)
#
macro(myproject_target_link_cuda target)
  # optional named CUDA_WARNINGS
  set(oneValueArgs CUDA_WARNINGS)
  cmake_parse_arguments(
    _cuda_args
    ""
    "${oneValueArgs}"
    ""
    ${ARGN})

  # add CUDA to cmake language
  enable_language(CUDA)

  # use the same C++ standard if not specified
  if("${CMAKE_CUDA_STANDARD}" STREQUAL "")
    set(CMAKE_CUDA_STANDARD "${CMAKE_CXX_STANDARD}")
  endif()

  # -fPIC
  set_target_properties(${target} PROPERTIES POSITION_INDEPENDENT_CODE ON)

  # We need to explicitly state that we need all CUDA files in the
  # ${target} library to be built with -dc as the member functions
  # could be called by other libraries and executables
  set_target_properties(${target} PROPERTIES CUDA_SEPARABLE_COMPILATION ON)

  if(APPLE)
    # We need to add the path to the driver (libcuda.dylib) as an rpath,
    # so that the static cuda runtime can find it at runtime.
    set_property(TARGET ${target} PROPERTY BUILD_RPATH ${CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES})
  endif()

  if(WIN32 AND "$ENV{VSCMD_VER}" STREQUAL "")
    message(
      WARNING
        "Compiling CUDA on Windows outside the Visual Studio Command prompt or without running `vcvarsall.bat x64` probably fails"
    )
  endif()
endmacro()
