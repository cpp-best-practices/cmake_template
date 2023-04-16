
macro(enable_hardening target)
  if(MSVC)
    target_compile_options(${target} INTERFACE /sdl /DYNAMICBASE /guard:cf /NXCOMPAT)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU")
    target_compile_definitions(${target} INTERFACE _GLIBCXX_ASSERTIONS)
    target_compile_options(${target} INTERFACE -include "${CMAKE_SOURCE_DIR}/cmake/_FORTIFY_SOURCE.hpp")
    target_compile_options(${target} INTERFACE -fstack-protector-strong -fcf-protection -fstack-clash-protection)
    if (NOT WIN32)
      target_link_options(${target} INTERFACE -pie)
    endif()
  endif()


endmacro()
