const rl = @import("raylib");
const rg = @import("raygui");

const definitions = @import("../app_definitions.zig");
const WIDTH = definitions.WIDTH;
const HEIGHT = definitions.HEIGHT;

const uiDefinitions = @import("ui_definitions.zig");
const uiControls = @import("ui_controls.zig");

var selectedIndex: usize = 0;

const MenuButton = @import("ui_definitions.zig").MenuButton;
const AudioManager = @import("../audio_manager.zig").AudioManager;

const MainMenuAction = enum {
    gameStart,
    options,
    quit,
};

// TODO: Architektur upgraden
const MainMenuEntry = struct {
    button: MenuButton,
    action: MainMenuAction,
};

pub fn draw(app: *definitions.AppState, audioManager: *AudioManager) void {
    rl.drawText("MAIN MENU", WIDTH / 2 - 150, 20, 50, rl.Color.ray_white);

    //TODO: AUDIO MENU
    audioManager.playMusic(.menu);

    const buttons = [_]MenuButton{
        MenuButton.initCentered("Game Start", WIDTH / 2.0, HEIGHT / 4.0, .game),
        MenuButton.initCentered("OPTIONS", WIDTH / 2.0, HEIGHT / 4.0 * 2, .options),
        MenuButton.initCentered("QUIT", WIDTH / 2.0, HEIGHT / 4.0 * 3, .quit),
    };

    uiControls.updateSelection(&selectedIndex, buttons.len);
    uiControls.updateSelectionFromMouse(&selectedIndex, &buttons);

    for (buttons, 0..) |button, index| {
        const selected = index == selectedIndex;
        if (button.draw(selected)) {
            app.currentScreen = button.action;
        }
    }

    if (uiControls.activatePressed()) {
        app.currentScreen = buttons[selectedIndex].action;
    }
}
