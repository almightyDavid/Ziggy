const rl = @import("raylib");

const Player = @import("player.zig").Player;
const Camera = @import("camera.zig").Camera;

const level = @import("level.zig");
const Assets = @import("../assets.zig").Assets;

const SCREEN_WIDTH = @import("../app_definitions.zig").WIDTH;
const SCREEN_HEIGHT = @import("../app_definitions.zig").HEIGHT;

pub const Game = struct {
    player: Player,
    camera: Camera,
    assets: Assets,

    pub fn init() !Game {
        var player = Player.init(.{ .x = 80.0, .y = 400.0 });
        var camera = Camera.init(SCREEN_WIDTH, SCREEN_HEIGHT, level.levelWidth, level.levelHeight, &player);

        camera.update(&player);

        return .{
            .player = player,
            .camera = camera,
            .assets = try Assets.load(),
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

        level.update(deltaTime, &self.player);

        for (self.player.projectilesSlice()) |*projectile| {
            level.resolveProjectileCollision(projectile);
        }

        if (self.player.position.y > 1600.0) {
            self.reset();
        }
        self.camera.update(&self.player);

        if (!self.player.alive) {
            self.reset();
        }
    }

    pub fn draw(self: *const Game) void {
        rl.clearBackground(rl.Color.sky_blue);
        rl.beginMode2D(self.camera.camera);

        level.draw(&self.assets);
        self.player.draw(&self.assets);

        rl.endMode2D();

        rl.drawText(
            "A/D: Move   Space: Jump   J: Teleport",
            20,
            20,
            20,
            rl.Color.black,
        );

        drawHealth(self);
    }

    pub fn drawHealth(self: *const Game) void {
        const posX: i32 = 20;
        const posY = SCREEN_HEIGHT - 40;
        const spacing = 40;
        var i: i32 = 0;
        while (i < self.player.health) : (i += 1) {
            rl.drawText("X", posX + i * spacing, posY, 40, rl.Color.red);
        }
    }

    pub fn reset(self: *Game) void {
        self.player = Player.init(.{
            .x = 80.0,
            .y = 400.0,
        });
        level.reset();
    }
};
