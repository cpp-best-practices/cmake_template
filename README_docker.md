## Docker Instructions

If you have [Docker](https://www.docker.com/) installed, you can run this
in your terminal, when the Dockerfile is inside the `.devcontainer` directory:

```bash
docker build -f ./.devcontainer/Dockerfile --tag=my_project:latest .
docker run -it my_project:latest
```

This command will put you in a `bash` session in a Red Hat UBI 10 Docker container,
with all of the tools listed in the [Dependencies](README_dependencies.md#dependencies) section already installed.
You will have GCC 14 (system default), GCC 15 (via gcc-toolset-15), and Clang 19
available, along with CMake, Ninja, Conan 2.0, clang-tidy, cppcheck,
include-what-you-use, ccache, doxygen, and graphviz.

The CC and CXX environment variables are set to GCC 14 by default.
To use GCC 15 instead, activate the toolset:

```bash
source /opt/rh/gcc-toolset-15/enable
```

Or set the compiler explicitly:

```bash
CC=/opt/rh/gcc-toolset-15/root/usr/bin/gcc CXX=/opt/rh/gcc-toolset-15/root/usr/bin/g++ cmake -S . -B ./build
```

If you wish to use clang as your default compiler, build the container with:

```bash
docker build --tag=my_project:latest --build-arg USE_CLANG=1 -f ./.devcontainer/Dockerfile .
```

You will be logged in as root, so you will see the `#` symbol as your prompt.

If you need to mount your local copy directly in the Docker image, see
[Docker volumes docs](https://docs.docker.com/storage/volumes/).
TLDR:

```bash
docker run -it \
	-v absolute_path_on_host_machine:absolute_path_in_guest_container \
	my_project:latest
```

You can configure and build [as directed above](#build) using these commands:

```bash
mkdir build
cmake -S . -B ./build
cmake --build ./build
```

You can configure and build using clang, without rebuilding the container,
with these commands:

```bash
mkdir build
CC=clang CXX=clang++ cmake -S . -B ./build
cmake --build ./build
```

All of the tools this project supports are installed in the Docker image;
enabling them is as simple as flipping a switch using the `ccmake` interface.
Be aware that some of the sanitizers conflict with each other, so be sure to
run them separately.
