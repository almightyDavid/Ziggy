const rl = @import("raylib");

const Player = @import("player.zig").Player;
const Camera = @import("camera.zig").Camera;

const level = @import("level.zig");

const SCREEN_WIDTH = @import("../app_definitions.zig").WIDTH;
const SCREEN_HEIGHT = @import("../app_definitions.zig").HEIGHT;

pub const Game = struct {
    player: Player,
    camera: Camera,

    pub fn init() Game {
        var player = Player.init(.{ .x = 80.0, .y = 400.0 });
        var camera = Camera.init(SCREEN_WIDTH, SCREEN_HEIGHT, level.levelWidth, level.levelHeight, &player);

        camera.update(&player);

        return .{
            .player = player,
            .camera = camera,
        };
    }

    pub fn update(self: *Game) void {
        const deltaTime = @min(
            rl.getFrameTime(),
            1.0 / 30.0,
        );

        self.player.update(
            deltaTime,
            level.platforms[0..],
        );

        level.update(deltaTime, self.player.getCenter());

        if (self.player.position.y > 1600.0) {
            self.reset();
        }
        self.camera.update(&self.player);
    }

    pub fn draw(self: Game) void {
        rl.clearBackground(rl.Color.sky_blue);
        rl.beginMode2D(self.camera.camera);
        defer rl.endMode2D();

        level.draw();
        self.player.draw();

        rl.drawText(
            "A/D: Move   Space: Jump   J: Teleport",
            20,
            20,
            20,
            rl.Color.black,
        );
    }

    pub fn reset(self: *Game) void {
        self.player = Player.init(.{
            .x = 80.0,
            .y = 400.0,
        });
        level.reset();
    }
};
