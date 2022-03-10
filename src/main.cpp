#include <functional>
#include <iostream>

#include <docopt/docopt.h>
#include <ftxui/component/captured_mouse.hpp>// for ftxui
#include <ftxui/component/component.hpp>// for Slider
#include <ftxui/component/screen_interactive.hpp>// for ScreenInteractive
#include <spdlog/spdlog.h>

// This file will be generated automatically when you run the CMake
// configuration step. It creates a namespace called `myproject`. You can modify
// the source template at `configured_files/config.hpp.in`.
#include <internal_use_only/config.hpp>

static constexpr auto USAGE =
  R"(intro

    Usage:
          intro
          intro (-h | --help)
          intro --version
 Options:
          -h --help     Show this screen.
          --version     Show version.
)";


struct GameBoard
{
  static constexpr std::size_t width = 5;
  static constexpr std::size_t height = 5;

  std::array<std::array<std::string, height>, width> strings;
  std::array<std::array<bool, height>, width> values{};

  void set(std::size_t x, std::size_t y, bool new_value)
  {
    values[x][y] = new_value;

    if (new_value) {
      strings[x][y] = " ON";
    } else {
      strings[x][y] = "OFF";
    }
  }

  bool get(std::size_t x, std::size_t y) { return values[x][y]; }

  GameBoard() { update_strings(); }

  void update_strings()
  {
    for (std::size_t x = 0; x < width; ++x) {
      for (std::size_t y = 0; y < height; ++y) { set(x, y, get(x, y)); }
    }
  }

  void toggle(std::size_t x, std::size_t y) { set(x, y, !get(x, y)); }

  void press(std::size_t x, std::size_t y)
  {
    if (x > 0) { toggle(x - 1, y); }
    if (y > 0) { toggle(x, y - 1); }
    if (x < width - 1) { toggle(x + 1, y); }
    if (y < height - 1) { toggle(x, y + 1); }
  }
};

int main(int argc, const char **argv)
{
  try {
    std::map<std::string, docopt::value> args = docopt::docopt(USAGE,
      { std::next(argv), std::next(argv, argc) },
      true,// show help if requested
      fmt::format("{} {}",
        myproject::cmake::project_name,
        myproject::cmake::project_version));// version string, acquired
                                            // from config.hpp via CMake

    using namespace ftxui;
    auto screen = ScreenInteractive::TerminalOutput();

    GameBoard gb;

    const auto make_buttons = [&] {
      std::vector<ftxui::Component> buttons;
      for (std::size_t x = 0; x < gb.width; ++x) {
        for (std::size_t y = 0; y < gb.height; ++y) {
          buttons.push_back(ftxui::Button(&gb.strings[x][y], [x, y, &gb] { gb.press(x,y); }));
        }
      }
      return buttons;
    };

    auto buttons = make_buttons();

    auto container = Container::Horizontal(buttons);

    auto make_layout = [&] {
      std::vector<ftxui::Element> columns;

      std::size_t idx = 0;

      for (std::size_t x = 0; x < gb.width; ++x) {
        std::vector<ftxui::Element> row;
        for (std::size_t y = 0; y < gb.height; ++y) {
          row.push_back(buttons[idx]->Render());
          ++idx;
        }
        columns.push_back(ftxui::hbox(std::move(row)));
      }

      return ftxui::vbox(std::move(columns));
    };

    auto renderer = Renderer(container, make_layout);


    /*
  return vbox({ text("Turn all boxes to 'on':"),
    text(""),
    hbox(toggle_1_selected == 0 ? color(Color::Green, quit_button->Render())
                                : color(Color::Blue, quit_button->Render())) });
                                */

    screen.Loop(renderer);

  } catch (const std::exception &e) {
    fmt::print("Unhandled exception in main: {}", e.what());
  }
}
