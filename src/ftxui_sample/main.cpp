#include <array>
#include <CLI/CLI.hpp>
#include <ftxui/component/captured_mouse.hpp>
#include <ftxui/component/component.hpp>
#include <ftxui/component/screen_interactive.hpp>
#include <functional>
#include <internal_use_only/config.hpp>
#include <iostream>
#include <lefticus/tools/non_promoting_ints.hpp>
#include <optional>
#include <random>
#include <spdlog/spdlog.h>

template <std::size_t Width, std::size_t Height>
class GameBoard {
  public:
    static constexpr std::size_t width  = Width;
    static constexpr std::size_t height = Height;

    std::size_t move_count{0};

  private:
    std::array<std::array<std::string, height>, width> _strings;
    std::array<std::array<bool, height>, width>        _values{};

  public:
    GameBoard() {
        visit([](const auto cur_x, const auto cur_y, auto &gameboard) {
            gameboard.set(cur_x, cur_y, true);
        });
    }

    [[nodiscard]] auto get(std::size_t cur_x, std::size_t cur_y) const -> bool {
        return _values.at(cur_x).at(cur_y);
    }

    [[nodiscard]] auto get(std::size_t cur_x, std::size_t cur_y) -> bool & {
        return _values.at(cur_x).at(cur_y);
    }

    auto get_string(std::size_t cur_x, std::size_t cur_y) -> std::string & {
        return _strings.at(cur_x).at(cur_y);
    }

    auto press(std::size_t cur_x, std::size_t cur_y) -> void {
        ++move_count;
        toggle(cur_x, cur_y);
        if (cur_x > 0) {
            toggle(cur_x - 1, cur_y);
        }
        if (cur_y > 0) {
            toggle(cur_x, cur_y - 1);
        }
        if (cur_x < width - 1) {
            toggle(cur_x + 1, cur_y);
        }
        if (cur_y < height - 1) {
            toggle(cur_x, cur_y + 1);
        }
    }

    auto set(std::size_t cur_x, std::size_t cur_y, bool new_value) -> void {
        get(cur_x, cur_y) = new_value;
        if (new_value) {
            get_string(cur_x, cur_y) = " ON";
        } else {
            get_string(cur_x, cur_y) = "OFF";
        }
    }

    [[nodiscard]] auto solved() const -> bool {
        for (std::size_t cur_x = 0; cur_x < width; ++cur_x) {
            for (std::size_t cur_y = 0; cur_y < height; ++cur_y) {
                if (!get(cur_x, cur_y)) {
                    return false;
                }
            }
        }
        return true;
    }

    auto toggle(std::size_t cur_x, std::size_t cur_y) -> void {
        set(cur_x, cur_y, !get(cur_x, cur_y));
    }

    auto update_strings() -> void {
        for (std::size_t cur_x = 0; cur_x < width; ++cur_x) {
            for (std::size_t cur_y = 0; cur_y < height; ++cur_y) {
                set(cur_x, cur_y, get(cur_x, cur_y));
            }
        }
    }

    auto visit(auto visitor) -> void {
        for (std::size_t cur_x = 0; cur_x < width; ++cur_x) {
            for (std::size_t cur_y = 0; cur_y < height; ++cur_y) {
                visitor(cur_x, cur_y, *this);
            }
        }
    }
};

auto consequence_game() -> void {
    GameBoard<3, 3> game_board;
    std::string     quit_text;

    auto screen = ftxui::ScreenInteractive::TerminalOutput();

    const auto update_quit_text = [&quit_text](const auto &game_board_param) {
        quit_text = fmt::format("Quit ({} moves)", game_board_param.move_count);
        if (game_board_param.solved()) {
            quit_text += " Solved!";
        }
    };

    const auto make_buttons = [&] {
        std::vector<ftxui::Component> buttons;
        for (std::size_t cur_x = 0; cur_x < decltype(game_board)::width; ++cur_x) {
            for (std::size_t cur_y = 0; cur_y < decltype(game_board)::height; ++cur_y) {
                buttons.push_back(ftxui::Button(&game_board.get_string(cur_x, cur_y), [=, &game_board] {
                    if (!game_board.solved()) {
                        game_board.press(cur_x, cur_y);
                    }
                    update_quit_text(game_board);
                }));
            }
        }
        return buttons;
    };

    auto buttons     = make_buttons();
    auto quit_button = ftxui::Button(&quit_text, screen.ExitLoopClosure());

    auto make_layout = [&] {
        std::vector<ftxui::Element> rows;
        std::size_t                 idx = 0;

        for (std::size_t cur_x = 0; cur_x < decltype(game_board)::width; ++cur_x) {
            std::vector<ftxui::Element> row;
            for (std::size_t cur_y = 0; cur_y < decltype(game_board)::height; ++cur_y) {
                row.push_back(buttons[idx]->Render());
                ++idx;
            }
            rows.push_back(ftxui::hbox(std::move(row)));
        }

        rows.push_back(ftxui::hbox({quit_button->Render()}));
        return ftxui::vbox(std::move(rows));
    };

    static constexpr int randomization_iterations = 100;
    static constexpr int random_seed              = 42;

    std::mt19937 gen32{random_seed}; // NOLINT(cert-msc32-c, cert-msc51-cpp)

    // NOLINTBEGIN(misc-const-correctness)
    std::uniform_int_distribution<std::size_t> cur_x(static_cast<std::size_t>(0), decltype(game_board)::width - 1);
    std::uniform_int_distribution<std::size_t> cur_y(static_cast<std::size_t>(0), decltype(game_board)::height - 1);
    // NOLINTEND(misc-const-correctness)

    for (int i = 0; i < randomization_iterations; ++i) {
        game_board.press(cur_x(gen32), cur_y(gen32));
    }
    game_board.move_count = 0;
    update_quit_text(game_board);

    auto all_buttons = buttons;
    all_buttons.push_back(quit_button);
    auto container = ftxui::Container::Horizontal(all_buttons);
    auto renderer  = ftxui::Renderer(container, make_layout);
    screen.Loop(renderer);
}

struct Color {
    lefticus::tools::uint_np8_t R{static_cast<std::uint8_t>(0)};
    lefticus::tools::uint_np8_t G{static_cast<std::uint8_t>(0)};
    lefticus::tools::uint_np8_t B{static_cast<std::uint8_t>(0)};
};

// A simple way of representing a bitmap on screen using only characters
struct Bitmap : ftxui::Node {
  private:
    std::size_t        _width;
    std::size_t        _height;
    std::vector<Color> _pixels = std::vector<Color>(_width * _height, Color{});

  public:
    Bitmap(std::size_t width, std::size_t height) : // NOLINT(bugprone-easily-swappable-parameters)
        _width(width),
        _height(height) {}

    auto at(std::size_t cur_x, std::size_t cur_y) -> Color & {
        return _pixels.at(_width * cur_y + cur_x);
    }

    [[nodiscard]] auto data() noexcept -> auto & {
        return _pixels;
    }

    [[nodiscard]] auto height() const noexcept {
        return _height;
    }

    [[nodiscard]] auto width() const noexcept {
        return _width;
    }

    auto ComputeRequirement() -> void override {
        requirement_ = ftxui::Requirement{
            .min_x = static_cast<int>(_width),
            .min_y = static_cast<int>(_height / 2),
            .selected_box{0, 0, 0, 0}
        };
    }

    auto Render(ftxui::Screen &screen) -> void override {
        for (std::size_t cur_x = 0; cur_x < _width; ++cur_x) {
            for (std::size_t cur_y = 0; cur_y < _height / 2; ++cur_y) {
                auto &pixel =
                    screen.PixelAt(box_.x_min + static_cast<int>(cur_x), box_.y_min + static_cast<int>(cur_y));
                pixel.character = "▄";

                const auto &top_color    = at(cur_x, cur_y * 2);
                const auto &bottom_color = at(cur_x, cur_y * 2 + 1);

                pixel.background_color = ftxui::Color{top_color.R.get(), top_color.G.get(), top_color.B.get()};
                pixel.foreground_color = ftxui::Color{bottom_color.R.get(), bottom_color.G.get(), bottom_color.B.get()};
            }
        }
    }
};

auto game_iteration_canvas() -> void {
    // this should probably have a `bitmap` helper function that does what cur_you
    // expect similar to the other parts of FTXUI

    auto bitmap       = std::make_shared<Bitmap>(50, 50); // NOLINT(*-magic-numbers)
    auto small_bitmap = std::make_shared<Bitmap>(6, 6);   // NOLINT(*-magic-numbers)

    double      fps     = 0;
    std::size_t max_row = 0;
    std::size_t max_col = 0;

    // TODO: add total game time clock also, not just current elapsed time
    auto game_iteration = [&](const std::chrono::steady_clock::duration elapsed_time) {
        // in here we simulate however much game time has elapsed.
        // Update animations, run character AI, whatever, update stats, etc

        // this isn't actually timing based for now,
        // it's just updating the display however fast it can
        fps = 1.0
            / (static_cast<double>(std::chrono::duration_cast<std::chrono::microseconds>(elapsed_time).count())
               / 1'000'000.0); // NOLINT(*-magic-numbers)

        for (std::size_t row = 0; row < max_row; ++row) {
            for (std::size_t col = 0; col < bitmap->width(); ++col) {
                ++(bitmap->at(col, row).R);
            }
        }

        for (std::size_t row = 0; row < bitmap->height(); ++row) {
            for (std::size_t col = 0; col < max_col; ++col) {
                ++(bitmap->at(col, row).G);
            }
        }

        // for the fun of it, let's have a second window doing interesting
        // things
        auto &small_bm_pixel =
            small_bitmap->data().at(static_cast<std::size_t>(elapsed_time.count()) % small_bitmap->data().size());

        switch (elapsed_time.count() % 3) {
            case 0:
                small_bm_pixel.R += 11; // NOLINT(*-magic-numbers)
                break;
            case 1:
                small_bm_pixel.G += 11; // NOLINT(*-magic-numbers)
                break;
            case 2:
                small_bm_pixel.B += 11; // NOLINT(*-magic-numbers)
                break;
        }

        ++max_row;
        if (max_row >= bitmap->height()) {
            max_row = 0;
        }
        ++max_col;
        if (max_col >= bitmap->width()) {
            max_col = 0;
        }
    };

    auto last_time = std::chrono::steady_clock::now();
    auto screen    = ftxui::ScreenInteractive::TerminalOutput();
    int  counter   = 0;

    auto make_layout = [&] {
        // This code actually processes the draw event
        const auto new_time = std::chrono::steady_clock::now();

        ++counter;
        // we will dispatch to the game_iteration function, where the work happens
        game_iteration(new_time - last_time);
        last_time = new_time;

        // now actually draw the game elements
        return ftxui::hbox({bitmap | ftxui::border,
                            ftxui::vbox({ftxui::text("Frame: " + std::to_string(counter)),
                                         ftxui::text("FPS: " + std::to_string(fps)),
                                         small_bitmap | ftxui::border})});
    };

    auto              renderer            = ftxui::Renderer(make_layout);
    std::atomic<bool> refresh_ui_continue = true;

    // This thread exists to make sure that the event queue has an event to
    // process at approximately a rate of 30 FPS
    std::thread refresh_ui([&] {
        while (refresh_ui_continue) {
            using namespace std::chrono_literals;
            std::this_thread::sleep_for(1.0s / 30.0); // NOLINT magic numbers
            screen.PostEvent(ftxui::Event::Custom);
        }
    });

    screen.Loop(renderer);
    refresh_ui_continue = false;
    refresh_ui.join();
}

auto main([[maybe_unused]] int argc, [[maybe_unused]] const char **argv) -> int try {
    CLI::App app{fmt::format("{} version {}", myproject::cmake::project_name, myproject::cmake::project_version)};

    std::optional<std::string> message;
    app.add_option("-m,--message", message, "A message to print back out");
    bool show_version = false;
    app.add_flag("--version", show_version, "Show version information");

    bool  is_turn_based = false;
    auto *turn_based    = app.add_flag("--turn_based", is_turn_based);

    bool  is_loop_based = false;
    auto *loop_based    = app.add_flag("--loop_based", is_loop_based);

    turn_based->excludes(loop_based);
    loop_based->excludes(turn_based);

    CLI11_PARSE(app, argc, argv);

    if (show_version) {
        fmt::print("{}\n", myproject::cmake::project_version);
        return EXIT_SUCCESS;
    }

    if (is_turn_based) {
        consequence_game();
    } else {
        game_iteration_canvas();
    }
} catch (const std::exception &e) {
    spdlog::error("Unhandled exception in main: {}", e.what());
}
