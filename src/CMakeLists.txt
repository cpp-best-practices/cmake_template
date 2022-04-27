find_package(fmt CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(CLI11 CONFIG REQUIRED)
find_package(ftxui CONFIG REQUIRED)

# Generic test that uses conan libs
add_executable(intro main.cpp)

target_link_libraries(
  intro
  PRIVATE project_options
          project_warnings
          CLI11::CLI11
          fmt::fmt
          spdlog::spdlog
          ftxui::screen
          ftxui::dom
          ftxui::component)

target_include_directories(intro PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")
