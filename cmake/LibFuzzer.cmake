function(myproject_check_libfuzzer_support var_name)
  set(LibFuzzerTestSource
      "
#include <cstdint>

extern \"C\" int LLVMFuzzerTestOneInput(const std::uint8_t *data, std::size_t size) {
  return 0;
}
    ")

  include(CheckCXXSourceCompiles)

  set(CMAKE_REQUIRED_FLAGS "-fsanitize=fuzzer")
  set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=fuzzer")
  check_cxx_source_compiles("${LibFuzzerTestSource}" ${var_name})

endfunction()
