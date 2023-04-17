
macro(enable_hardening target)
  if(MSVC)
    target_compile_options(${target} INTERFACE /sdl /DYNAMICBASE /guard:cf /NXCOMPAT)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU")
    target_compile_definitions(${target} INTERFACE _GLIBCXX_ASSERTIONS)
    target_compile_options(${target} INTERFACE -include "${CMAKE_SOURCE_DIR}/cmake/_FORTIFY_SOURCE.hpp")

    check_cxx_compiler_flag(-fpie PIE)
    if (PIE)
      target_compile_options(${target} INTERFACE -fpie)
      target_link_options(${target} INTERFACE -pie)
    endif()

    check_cxx_compiler_flag(-fstack-protector-strong STACK_PROTECTOR)
    if (STACK_PROTECTOR)
      target_compile_options(${target} INTERFACE -fstack-protector-strong)
    endif()

    check_cxx_compiler_flag(-fcf-protection CF_PROTECTION)
    if (CF_PROTECTION)
      target_compile_options(${target} INTERFACE -fcf-protection)
    endif()

    check_cxx_compiler_flag(-fclash-protection CLASH_PROTECTION)
    if (CLASH_PROTECTION)
      target_compile_options(${target} INTERFACE -fstack-clash-protection)
    endif()


  endif()


endmacro()
