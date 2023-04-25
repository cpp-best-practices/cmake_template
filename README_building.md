# Build Instructions

A full build has different steps:

1. Specifying the compiler using environment variables
2. Configuring the project
3. Building the project

For the subsequent builds, in case you change the source code, you only need to repeat the last step

## 1. Specify the compiler using environment variables

By default (if you don't set environment variables `CC` and `CXX`),
the system default compiler will be used.

CMake uses the environment variables CC and CXX to decide which compiler to use.
So to avoid the conflict issues only specify the compilers using these variables:

- MacOS/Ubuntu:

  - Permanently

    Open `~/.bashrc` using your text editor:

    ```shell
    gedit ~/.bashrc
    ```

    Add `CC` and `CXX` to point to the compilers:

    ```shell
    export CC="clang"
    export CXX="clang++"
    ```

    Save and close the file.

  - Temporarily

    - Clang

      ```shell
      CC="clang" CXX="clang++"
      ```

    - GCC

      ```shell
      CC="gcc" CXX="g++"
      ```

- Windows

  - Permanently

    - Clang

      ```powershell
      [Environment]::SetEnvironmentVariable("CC", "clang.exe", "User")
      [Environment]::SetEnvironmentVariable("CXX", "clang++.exe", "User")
      refreshenv
      ```

    - GCC

      ```powershell
      [Environment]::SetEnvironmentVariable("CC", "gcc.exe", "User")
      [Environment]::SetEnvironmentVariable("CXX", "g++.exe", "User")
      refreshenv
      ```

    - MSVC

      ```powershell
      [Environment]::SetEnvironmentVariable("CC", "cl.exe", "User")
      [Environment]::SetEnvironmentVariable("CXX", "cl.exe", "User")
      refreshenv
      ```

      Set the architecture using [vcvarsall](https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=vs-2019#vcvarsall-syntax):

      ```powershell
      vcvarsall.bat x64
      ```

  - Temporarily

    ```powershell
    $Env:CC="clang.exe"
    $Env:CXX="clang++.exe"
    ```

## 2. Configure your build

To configure the project, you could use `cmake`, or `ccmake` or `cmake-gui`.
Each of them are explained in the following:

- Configuring via cmake

  ```shell
  cmake -B ./build -S .
  ```

  Cmake will automatically create the `./build` folder if it does not exist, and it wil configure the project.

  Instead, if you have CMake version 3.21+, you can use one of the configuration presets that are listed in the CmakePresets.json file.

  ```shell
  cmake --preset <configure-preset> .
  cmake --build
  ```

- Configuring via ccmake

  ```shell
  ccmake -B ./build -S .
  ```

  Once `ccmake` has finished setting up, press 'c' to configure the project,
  press 'g' to generate, and 'q' to quit.

- Configuring via cmake-gui

  - Open cmake-gui from the project directory

    ```shell
    cmake-gui .
    ```

  - Set the build directory

    ![build_dir](https://user-images.githubusercontent.com/16418197/82524586-fa48e380-9af4-11ea-8514-4e18a063d8eb.jpg)

  - Configure the generator

    In cmake-gui, from the upper menu select `Tools/Configure`

    **Warning**: if you have set `CC` and `CXX` always choose the `use default native compilers` option.
    This picks `CC` and `CXX`. Don't change the compiler at this stage!

    - Windows - MinGW Makefiles

      Choose MinGW Makefiles as the generator

      ![mingw](https://user-images.githubusercontent.com/16418197/82769479-616ade80-9dfa-11ea-899e-3a8c31d43032.png)

    - Windows - Visual Studio generator and compiler

      You should have already set `C` and `CXX` to `cl.exe`

      Choose "Visual Studio 16 2019" as the generator

      ![default_vs](https://user-images.githubusercontent.com/16418197/82524696-32502680-9af5-11ea-9697-a42000e900a6.jpg)

    - Windows - Visual Studio generator and Clang Compiler

      You should have already set `C` and `CXX` to `clang.exe` and `clang++.exe`

      Choose "Visual Studio 16 2019" as the generator

      To tell Visual studio to use `clang-cl.exe`:

      - If you use the LLVM that is shipped with Visual Studio: write `ClangCl` under "optional toolset to use"

        ![visual_studio](https://user-images.githubusercontent.com/16418197/82781142-ae60ac00-9e1e-11ea-8c77-222b005a8f7e.png)

      - If you use an external LLVM: write [`LLVM_v142`](https://github.com/zufuliu/llvm-utils#llvm-for-visual-studio-2017-and-2019) under "optional toolset to use".

        ![visual_studio](https://user-images.githubusercontent.com/16418197/82769558-b3136900-9dfa-11ea-9f73-02ab8f9b0ca4.png)

  - Choose the Cmake options and then generate

    ![generate](https://user-images.githubusercontent.com/16418197/82781591-c97feb80-9e1f-11ea-86c8-f2748b96f516.png)

## 3. Build the project

Once you have selected all the options you would like to use,
you can build the project (all targets):

```shell
cmake --build ./build
```

For Visual Studio, give the build configuration
(Release, RelWithDeb, Debug, etc) like the following:

```powershell
cmake --build ./build -- /p:configuration=Release
```

## Running the tests

You can use the `ctest` command run the tests.

```shell
cd ./build
ctest -C Debug
cd ../
```
