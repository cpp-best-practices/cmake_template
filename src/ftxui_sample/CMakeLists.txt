add_executable(intro main.cpp)

target_link_libraries(
  intro
  PRIVATE myproject::myproject_options
          myproject::myproject_warnings)

target_link_system_libraries(
  intro
  PRIVATE
          CLI11::CLI11
          fmt::fmt
          spdlog::spdlog
          lefticus::tools
          ftxui::screen
          ftxui::dom
          ftxui::component)

target_include_directories(intro PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")

if(MSVC AND myproject_ENABLE_SANITIZER_ADDRESS)
    cmake_path(GET CMAKE_CXX_COMPILER PARENT_PATH MSVC_TOOLS_DIR)
    install(
        FILES 
            "${MSVC_TOOLS_DIR}/clang_rt.asan_dbg_dynamic-x86_64.dll"
            "${MSVC_TOOLS_DIR}/clang_rt.asan_dbg_dynamic-x86_64.pdb"
            "${MSVC_TOOLS_DIR}/clang_rt.asan_dynamic-x86_64.dll"
            "${MSVC_TOOLS_DIR}/clang_rt.asan_dynamic-x86_64.pdb"
        TYPE BIN
    )
endif()
