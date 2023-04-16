
macro(enable_hardening target)
  if(MSVC)
    target_compile_options(${target} INTERFACE /sdl /DYNAMICBASE /guard:cf /NXCOMPAT)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU")
    target_compile_definitions(${target} INTERFACE _GLIBCXX_ASSERTIONS _FORTIFY_SOURCE=3)
    target_compile_options(${target} INTERFACE -fstack-protector-strong -fcf-protection -fstack-clash-protection -fpie)
    target_link_options(${target} INTERFACE -pie)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    target_compile_options(${target} INTERFACE -mcet)
  else()

  endif()
endmacro()
