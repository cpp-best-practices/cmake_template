#include <array>
#include <functional>
#include <iostream>
#include <random>

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


template<std::size_t Width, std::size_t Height> struct GameBoard
{
  static constexpr std::size_t width = Width;
  static constexpr std::size_t height = Height;

  std::array<std::array<std::string, height>, width> strings;
  std::array<std::array<bool, height>, width> values{};

  std::size_t move_count{ 0 };

  std::string &get_string(std::size_t x, std::size_t y) { return strings.at(x).at(y); }


  void set(std::size_t x, std::size_t y, bool new_value)
  {
    get(x, y) = new_value;

    if (new_value) {
      get_string(x, y) = " ON";
    } else {
      get_string(x, y) = "OFF";
    }
  }

  void visit(auto visitor)
  {
    for (std::size_t x = 0; x < width; ++x) {
      for (std::size_t y = 0; y < height; ++y) { visitor(x, y, *this); }
    }
  }

  [[nodiscard]] bool get(std::size_t x, std::size_t y) const { return values.at(x).at(y); }

  [[nodiscard]] bool &get(std::size_t x, std::size_t y) { return values.at(x).at(y); }

  GameBoard()
  {
    visit([](const auto x, const auto y, auto &gameboard) { gameboard.set(x, y, true); });
  }

  void update_strings()
  {
    for (std::size_t x = 0; x < width; ++x) {
      for (std::size_t y = 0; y < height; ++y) { set(x, y, get(x, y)); }
    }
  }

  void toggle(std::size_t x, std::size_t y) { set(x, y, !get(x, y)); }

  void press(std::size_t x, std::size_t y)
  {
    ++move_count;
    toggle(x, y);
    if (x > 0) { toggle(x - 1, y); }
    if (y > 0) { toggle(x, y - 1); }
    if (x < width - 1) { toggle(x + 1, y); }
    if (y < height - 1) { toggle(x, y + 1); }
  }

  [[nodiscard]] bool solved() const
  {
    for (std::size_t x = 0; x < width; ++x) {
      for (std::size_t y = 0; y < height; ++y) {
        if (!get(x, y)) { return false; }
      }
    }

    return true;
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

    auto screen = ftxui::ScreenInteractive::TerminalOutput();

    GameBoard<3, 3> gb;

    std::string quit_text;

    const auto update_quit_text = [&quit_text](const auto &game_board) {
      quit_text = fmt::format("Quit ({} moves)", game_board.move_count);
      if (game_board.solved()) { quit_text += " Solved!"; }
    };

    const auto make_buttons = [&] {
      std::vector<ftxui::Component> buttons;
      for (std::size_t x = 0; x < gb.width; ++x) {
        for (std::size_t y = 0; y < gb.height; ++y) {
          buttons.push_back(ftxui::Button(&gb.get_string(x, y), [=, &gb] {
            if (!gb.solved()) { gb.press(x, y); }
            update_quit_text(gb);
          }));
        }
      }
      return buttons;
    };

    auto buttons = make_buttons();

    auto quit_button = ftxui::Button(&quit_text, screen.ExitLoopClosure());

    auto make_layout = [&] {
      std::vector<ftxui::Element> rows;

      std::size_t idx = 0;

      for (std::size_t x = 0; x < gb.width; ++x) {
        std::vector<ftxui::Element> row;
        for (std::size_t y = 0; y < gb.height; ++y) {
          row.push_back(buttons[idx]->Render());
          ++idx;
        }
        rows.push_back(ftxui::hbox(std::move(row)));
      }

      rows.push_back(ftxui::hbox({ quit_button->Render() }));

      return ftxui::vbox(std::move(rows));
    };


    static constexpr int randomization_iterations = 100;
    static constexpr int random_seed = 42;

    std::mt19937 gen32{ random_seed };// NOLINT
    std::uniform_int_distribution<std::size_t> x(static_cast<std::size_t>(0), gb.width - 1);
    std::uniform_int_distribution<std::size_t> y(static_cast<std::size_t>(0), gb.height - 1);

    for (int i = 0; i < randomization_iterations; ++i) { gb.press(x(gen32), y(gen32)); }
    gb.move_count = 0;
    update_quit_text(gb);

    auto all_buttons = buttons;
    all_buttons.push_back(quit_button);
    auto container = ftxui::Container::Horizontal(all_buttons);

    auto renderer = ftxui::Renderer(container, make_layout);

    screen.Loop(renderer);


  } catch (const std::exception &e) {
    fmt::print("Unhandled exception in main: {}", e.what());
  }
}
