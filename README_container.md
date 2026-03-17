## Container Instructions

The `.devcontainer/Containerfile` provides a fully configured build environment
based on Red Hat UBI 10. Any OCI-compatible container runtime works: Podman,
Docker, Apple Containers, nerdctl, etc.

The examples below use `podman`. Replace with `docker` or your runtime of choice.

### Building and running the container

```bash
podman build -f ./.devcontainer/Containerfile --tag=my_project:latest .
podman run -it my_project:latest
```

This will drop you into a `bash` session with all tools pre-installed:
GCC 14 (system default), GCC 15 (via gcc-toolset-15), Clang 19, CMake, Ninja,
Conan 2.0, clang-tidy, cppcheck, include-what-you-use, ccache, doxygen, and
graphviz.

### Selecting compilers

The CC and CXX environment variables default to GCC 14. To use GCC 15,
activate the toolset inside the container. This sets PATH, LD_LIBRARY_PATH,
and other variables so the compiler finds its own libstdc++, headers, and
binutils instead of the system GCC 14 ones:

```bash
source /opt/rh/gcc-toolset-15/enable
cmake -S . -B ./build
cmake --build ./build
```

Do not just set CC/CXX to the GCC 15 paths without sourcing the enable
script. The compiler would still pick up GCC 14 system headers and libraries,
which can cause ABI mismatches or missing C++ library features.

To build the container image with Clang as the default compiler:

```bash
podman build --tag=my_project:latest --build-arg USE_CLANG=1 -f ./.devcontainer/Containerfile .
```

You can also switch to Clang at configure time without rebuilding the image:

```bash
CC=clang CXX=clang++ cmake -S . -B ./build
cmake --build ./build
```

### Mounting the source tree

To mount your local checkout into the container:

```bash
podman run -it \
	-v absolute_path_on_host:absolute_path_in_container \
	my_project:latest
```

### Building the project

```bash
cmake -S . -B ./build
cmake --build ./build
```

All static analysis tools are installed in the image. Enable or disable them
with `ccmake` or by passing cache variables on the command line. Be aware that
some sanitizers conflict with each other, so run them separately.
