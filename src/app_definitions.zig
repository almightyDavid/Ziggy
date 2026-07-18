pub const WIDTH = 1280;
pub const HEIGHT = 720;

pub const Screen = enum {
    mainMenu,
    game,
    options,
    quit,
};

pub const AppState = struct {
    currentScreen: Screen = .mainMenu,
    windowWidth: i32 = WIDTH,
    windowHeight: i32 = HEIGHT,
};
