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
    std::vector<std::string> toggle_1_entries = {
      "On",
      "Off",
    };
    std::vector<std::string> toggle_2_entries = {
      "Enabled",
      "Disabled",
    };
    std::vector<std::string> toggle_3_entries = {
      "10€",
      "0€",
    };
    std::vector<std::string> toggle_4_entries = {
      "Nothing",
      "One element",
      "Several elements",
    };

    auto screen = ScreenInteractive::TerminalOutput();

    int toggle_1_selected = 0;
    int toggle_2_selected = 0;
    int toggle_3_selected = 0;
    int toggle_4_selected = 0;
    Component toggle_1 = Toggle(&toggle_1_entries, &toggle_1_selected);
    Component toggle_2 = Toggle(&toggle_2_entries, &toggle_2_selected);
    Component toggle_3 = Toggle(&toggle_3_entries, &toggle_3_selected);
    Component toggle_4 = Toggle(&toggle_4_entries, &toggle_4_selected);
    auto quit_button = Button("Save & Quit", screen.ExitLoopClosure());

    auto container = Container::Vertical({ toggle_1, toggle_2, toggle_3, toggle_4, quit_button });

    auto renderer = Renderer(container, [&] {
      return vbox({ text("Choose your options:"),
        text(""),
        hbox(text(" * Poweroff on startup      : "), toggle_1->Render()),
        hbox(text(" * Out of process           : "), toggle_2->Render()),
        hbox(text(" * Price of the information : "), toggle_3->Render()),
        hbox(text(" * Number of elements       : "), toggle_4->Render()),
        text(""),
        hbox(toggle_1_selected == 0 ? color(Color::Green, quit_button->Render())
                                    : color(Color::Blue, quit_button->Render())) });
    });

    screen.Loop(renderer);

  } catch (const std::exception &e) {
    fmt::print("Unhandled exception in main: {}", e.what());
  }
}
