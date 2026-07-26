const rl = @import("raylib");
const Collider = @import("collision.zig").Collider;

pub const Projectile = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    active: bool = false,
    damage: i32 = 1,

    size: rl.Vector2 = .{
        .x = 16.0,
        .y = 8.0,
    },

    pub fn empty() Projectile {
        return .{ .position = .{ .x = 0.0, .y = 0.0 }, .velocity = .{ .x = 0.0, .y = 0.0 }, .active = false, .damage = 1 };
    }

    pub fn spawn(position: rl.Vector2, direction: f32) Projectile {
        return .{
            .position = position,
            .velocity = .{
                .x = 1000.0 * direction,
                .y = 0.0,
            },
            .active = true,
            .damage = 1,
        };
    }

    pub fn update(self: *Projectile, deltaTime: f32) void {
        if (!self.active) return;

        self.position.x += self.velocity.x * deltaTime;
        self.position.y += self.velocity.y * deltaTime;
    }

    pub fn deactivate(self: *Projectile) void {
        self.active = false;
        self.velocity = .{
            .x = 0.0,
            .y = 0.0,
        };
    }

    pub fn getRectangle(self: Projectile) rl.Rectangle {
        return .{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
    }

    pub fn getCollider(self: Projectile) Collider {
        return .{ .rect = .{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        } };
    }

    pub fn isOut(self: Projectile, levelWidth: f32) bool {
        if (self.position.x < 0.0) {
            return true;
        }
        if (self.position.x > levelWidth) {
            return true;
        }
        return false;
    }

    // TODO: make work universally, or stay with rect forever
    pub fn draw(self: Projectile, texture: rl.Texture2D) void {
        if (!self.active) return;

        const source = rl.Rectangle{
            .x = 0.0,
            .y = 0.0,
            .width = @floatFromInt(texture.width),
            .height = @floatFromInt(texture.height),
        };

        const destination = rl.Rectangle{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };

        rl.drawTexturePro(texture, source, destination, .{ .x = 0.0, .y = 0.0 }, 0.0, rl.Color.white);
    }
};
