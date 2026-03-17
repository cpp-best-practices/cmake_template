from conan import ConanFile
from conan.tools.cmake import CMakeToolchain


class MyProjectConan(ConanFile):
    name = "myproject"
    version = "0.0.2"
    settings = "os", "arch", "compiler", "build_type"
    generators = "CMakeDeps"

    def requirements(self):
        self.requires("fmt/[>=11.0 <13.0]")
        self.requires("spdlog/[>=1.14.0 <2.0]")
        self.requires("catch2/[>=3.7.0 <4.0]")
        self.requires("trompeloeil/[>=49 <50]")
        self.requires("cli11/[>=2.4.0 <3.0]")
        self.requires("ftxui/[>=5.0 <7.0]")

        # ── Commented-out packages ────────────────────────────────────
        # Uncomment the ones your project needs. These serve as
        # ready-to-use examples with tested version ranges.
        #
        # Reflection & type support
        #self.requires("magic_enum/[>=0.9 <1.0]")
        #self.requires("gsl-lite/[>=1.0 <2.0]")
        #
        # Serialization & configuration
        #self.requires("nlohmann_json/[>=3.11 <4.0]")
        #self.requires("tomlplusplus/[>=3.3 <4.0]")
        #self.requires("inja/[>=3.4 <4.0]")
        #
        # Networking & RPC
        #self.requires("grpc/[>=1.67 <2.0]")
        #self.requires("protobuf/[>=5.29 <7.0]")
        #self.requires("libssh2/[>=1.11 <2.0]")
        #
        # Database
        #self.requires("libpqxx/[>=7.9 <9.0]")
        #
        # Process management
        #self.requires("reproc/[>=14.2 <15.0]")

        # ── Version range cheat-sheet ─────────────────────────────────
        #
        # Exact version (reproducible, no flexibility):
        #   self.requires("spdlog/1.14.1")
        #
        # Semver-compatible range (patch updates only):
        #   self.requires("spdlog/[~1.14]")        # >=1.14.0 <1.15.0
        #
        # Minor-update range:
        #   self.requires("spdlog/[>=1.14.0 <2.0]") # any 1.x from 1.14+
        #
        # Override a transitive dependency:
        #   self.requires("protobuf/5.29.6", override=True)
        #
        # Package with options:
        #   self.requires("spdlog/[>=1.14.0 <2.0]",
        #                 options={"use_std_fmt": True})
        #   self.requires("reproc/[>=14.2 <15.0]",
        #                 options={"with_cxx": True})

    def generate(self):
        tc = CMakeToolchain(self)
        tc.user_presets_path = False
        tc.generate()
