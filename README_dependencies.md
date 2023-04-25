# Dependencies

Note about install commands:

- for MacOS, we use [brew](https://brew.sh/)
- for Windows, we use [choco](https://chocolatey.org/install)
- In case of an error in cmake, make sure that the dependencies are on the PATH

## Too Long, Didn't Install

This is a really long list of dependencies, and it's easy to mess up. That's why:

- Docker

  We have a Docker image that's already set up for you. See the [Docker instructions](#docker-instructions).

- Setup-cpp

  We have [setup-cpp](https://github.com/aminya/setup-cpp) that is a cross-platform tool to install all the compilers and dependencies on the system.

  Please check [the setup-cpp documentation](https://github.com/aminya/setup-cpp) for more information.

  For example, on Windows, you can run the following to install llvm, cmake, ninja, ccache, and cppcheck.

  ```powershell
  curl -O "https://github.com/aminya/setup-cpp/releases/latest/download/setup-cpp-x64-windows.exe"
  ./setup_cpp_windows --ccache true --cmake true --compiler llvm --cppcheck true --ninja true
  RefreshEnv.cmd
  ```

## Necessary Dependencies

- A C++ compiler that supports C++17
  See [cppreference.com](https://en.cppreference.com/w/cpp/compiler_support)
  to see which features are supported by each compiler.
  The following compilers should work:

  - [Clang 6+](https://clang.llvm.org)

    - MacOS

      ```shell
      brew install llvm
      ```

    - Ubuntu

      ```shell
      bash -c "$(wget -O - <https://apt.llvm.org/llvm.sh>)"
      ```

    - Windows

      Visual Studio 2019 ships with LLVM (see the Visual Studio section). However, to install LLVM separately:

      ```powershell
      choco install llvm -y
      ```

      llvm-utils for using external LLVM with Visual Studio generator:

      ```powershell
      git clone <https://github.com/zufuliu/llvm-utils.git>
      cd llvm-utils/VS2017
      .\install.bat
      ```

  - [GCC 7+](https://gcc.gnu.org/)

    - MacOS

      ```shell
      brew install gcc
      ```

    - Ubuntu

      ```shell
      sudo apt install build-essential
      ```

    - Windows

      ```powershell
      choco install mingw -y
      ```

  - [MSVC 2019+](https://visualstudio.microsoft.com)

    On Windows, you need to install Visual Studio 2019 because of the SDK and libraries that ship with it.

    ```powershell
    choco install -y visualstudio2019community --package-parameters "add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --includeOptional --passive --locale en-US"
    ```

    Put MSVC compiler, Clang compiler, and vcvarsall.bat on the path:

    ```powershell
    choco install vswhere -y
    refreshenv
    ```

    Change to x86 for 32bit

    ```powershell
    $clpath = vswhere -products *-latest -prerelease -find **/Hostx64/x64/*
    $clangpath = vswhere -products * -latest -prerelease -find **/Llvm/bin/*
    $vcvarsallpath =  vswhere -products * -latest -prerelease -find **/Auxiliary/Build/*

    $path = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    refreshenv
    ```

- [Cmake 3.15+](https://cmake.org)

  - MacOS

    ```shell
    brew install cmake
    ```

  - Ubuntu

    ```shell
    sudo apt-get install cmake
    ```

  - Windows

    ```powershell
    choco install cmake -y
    ```

## Optional Dependencies

- [ccache](https://ccache.dev)

  - MacOS

    ```shell
    brew install ccache
    ```

  - Ubuntu

    ```shell
    sudo apt-get install ccache
    ```

  - Windows

    ```powershell
    choco install ccache -y
    ```

- [Cppcheck](http://cppcheck.sourceforge.net)

  - MacOS

    ```shell
    brew install cppcheck
    ```

  - Ubuntu

    ```shell
    sudo apt-get install cppcheck
    ```

  - Windows

    ```powershell
    choco install cppcheck -y
    ```

- [Doxygen](http://doxygen.nl)

  - MacOS

    ```shell
    brew install doxygen
    brew install graphviz
    ```

  - Ubuntu

    ```shell
    sudo apt-get install doxygen
    sudo apt-get install graphviz
    ```

  - Windows

    ```powershell
    choco install doxygen.install -y
    choco install graphviz -y
    ```

- [include-what-you-use](https://include-what-you-use.org)

  Follow instructions [here](https://github.com/include-what-you-use/include-what-you-use#how-to-install)
