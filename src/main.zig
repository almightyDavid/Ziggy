const rl = @import("raylib");
const rg = @import("raygui");

const main_menu = @import("ui/main_menu.zig");
const game = @import("game/game.zig");

const definitions = @import("app_definitions.zig");
const Renderer = @import("renderer.zig").Renderer;
const audioManager = @import("audio_manager.zig").AudioManager;
const Platformer = @import("game/game.zig").Game;

const WIDTH = definitions.WIDTH;
const HEIGHT = definitions.HEIGHT;

pub fn main() !void {
    rl.setConfigFlags(rl.ConfigFlags{
        .fullscreen_mode = true,
    });
    rl.initWindow(WIDTH, HEIGHT, "Ziggy");
    defer rl.closeWindow();

    var renderer = try Renderer.init(WIDTH, HEIGHT);
    defer renderer.deinit();

    rl.setTargetFPS(60);

    var app = definitions.AppState{
        .currentScreen = .mainMenu,
        .windowWidth = WIDTH,
        .windowHeight = HEIGHT,
    };

    // ---- AUDIO ----
    var audio = try audioManager.init();
    defer audio.deinit();

    // ---
    //audio.playMusic(.menu);

    var platformer = try Platformer.init();
    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(.f11)) {
            rl.toggleBorderlessWindowed();
        }

        renderer.beginLogicalDrawing();
        // ---
        //audio.update();

        switch (app.currentScreen) {
            .mainMenu => main_menu.draw(&app, &audio),
            .game => {
                platformer.update();
                platformer.draw();
            },
            .options => break,
            .quit => break,
        }

        renderer.endLogicalDrawing();
    }
}
