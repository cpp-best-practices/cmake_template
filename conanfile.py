from conan import ConanFile


class MyProjectConan(ConanFile):
    name = "myproject"
    version = "0.0.2"
    settings = "os", "arch", "compiler", "build_type"
    generators = "CMakeToolchain", "CMakeDeps"

    def requirements(self):
        self.requires("spdlog/[>=1.14.0 <2.0]")
        self.requires("catch2/[>=3.7.0 <4.0]")
        self.requires("cli11/[>=2.4.0 <3.0]")
        self.requires("ftxui/[>=5.0 <7.0]")
        # fmt is a transitive dependency of spdlog — no need to pin it
        # explicitly. It is available via find_package(fmt) in CMake.
