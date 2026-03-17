# Fuzz Testing

This directory contains a [libFuzzer](https://www.llvm.org/docs/LibFuzzer.html) harness
that exercises project code with randomly generated inputs, looking for crashes,
memory errors, and undefined behavior.

## How it works

The fuzzer entry point is `LLVMFuzzerTestOneInput()` in `fuzz_tester.cpp`. libFuzzer
calls this function repeatedly with mutated byte buffers. When combined with sanitizers
(ASAN, UBSAN, TSAN), the fuzzer can detect:

- Buffer overflows and use-after-free (Address Sanitizer)
- Signed integer overflow, null pointer dereference (Undefined Behavior Sanitizer)
- Data races (Thread Sanitizer)

The included example deliberately triggers signed integer overflow to demonstrate
how the fuzzer catches undefined behavior.

## Requirements

- Clang or GCC with `-fsanitize=fuzzer` support (libFuzzer)
- At least one sanitizer enabled (ASAN or TSAN recommended)

Fuzz testing is **not available** on MSVC or Emscripten.

## Building

Fuzz tests are built automatically when `myproject_BUILD_FUZZ_TESTS` is ON. This
defaults to ON when libFuzzer is available and a sanitizer is enabled:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug \
    -Dmyproject_ENABLE_SANITIZER_ADDRESS=ON
cmake --build build
```

To explicitly control fuzz test building:

```sh
cmake -S . -B build -Dmyproject_BUILD_FUZZ_TESTS=ON   # force on
cmake -S . -B build -Dmyproject_BUILD_FUZZ_TESTS=OFF   # force off
```

## Running

### Via CTest (short automated run)

CTest runs the fuzzer for a limited duration (default 10 seconds) as a smoke test:

```sh
cd build
ctest -R fuzz
```

Change the duration with the `FUZZ_RUNTIME` cache variable:

```sh
cmake -S . -B build -DFUZZ_RUNTIME=30   # 30 seconds
```

### Directly (extended fuzzing session)

For real fuzz testing, run the binary directly without a time limit:

```sh
./build/fuzz_test/fuzz_tester
```

libFuzzer will run indefinitely until it finds a bug or you press Ctrl+C. Useful flags:

```sh
# Run with a corpus directory (saves interesting inputs for replay)
mkdir -p corpus
./build/fuzz_test/fuzz_tester corpus/

# Limit to 60 seconds
./build/fuzz_test/fuzz_tester -max_total_time=60

# Use multiple parallel jobs
./build/fuzz_test/fuzz_tester -fork=4 -max_total_time=300

# Replay a crashing input
./build/fuzz_test/fuzz_tester crash-input-file
```

## Writing new fuzz targets

1. Create a new `.cpp` file with a `LLVMFuzzerTestOneInput` function
2. Add an `add_executable` and `target_link_libraries` entry in `CMakeLists.txt`
3. Link with `-fsanitize=fuzzer` and `-coverage`

```cpp
#include <cstddef>
#include <cstdint>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size)
{
  // Call your code with the fuzzed input
  my_function(Data, Size);
  return 0;
}
```

## Further reading

- [libFuzzer documentation](https://www.llvm.org/docs/LibFuzzer.html)
- [libFuzzer tutorial](https://github.com/google/fuzzing/blob/master/tutorial/libFuzzerTutorial.md)
- [Structure-aware fuzzing](https://github.com/google/fuzzing/blob/master/docs/structure-aware-fuzzing.md)
