const rl = @import("raylib");

const definitions = @import("../app_definitions.zig");
const Player = @import("player.zig").Player;

pub const Camera = struct {
    camera: rl.Camera2D,
    screenWidth: f32,
    screenHeight: f32,
    worldWidth: f32,
    worldHeight: f32,

    pub fn init(screenW: f32, screenH: f32, worldW: f32, worldH: f32, target: *const Player) Camera {
        return Camera{
            .camera = rl.Camera2D{
                .target = target.getCenter(),
                .offset = rl.Vector2{ .x = screenW / 2, .y = screenH / 2 },
                .rotation = 0,
                .zoom = 1.0,
            },
            .screenWidth = screenW,
            .screenHeight = screenH,
            .worldWidth = worldW,
            .worldHeight = worldH,
        };
    }

    pub fn setTarget(self: *Camera, target: *const Player) void {
        self.camera.target = target.getCenter();
    }

    pub fn clampCameraToWorld(self: *Camera) void {
        const halfScreenWidth = self.screenWidth / 2 / self.camera.zoom;
        const halfScreenHeight = self.screenHeight / 2 / self.camera.zoom;

        if (self.camera.target.x < halfScreenWidth) {
            self.camera.target.x = halfScreenWidth;
        }
        if (self.camera.target.y < halfScreenHeight) {
            self.camera.target.y = halfScreenHeight;
        }
        if (self.camera.target.x > self.worldWidth - halfScreenWidth) {
            self.camera.target.x = self.worldWidth - halfScreenWidth;
        }
        if (self.camera.target.y > self.worldHeight - halfScreenHeight) {
            self.camera.target.y = self.worldHeight - halfScreenHeight;
        }
    }

    pub fn update(self: *Camera, target: *const Player) void {
        self.setTarget(target);
        self.clampCameraToWorld();
    }
};
