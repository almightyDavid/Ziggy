const rl = @import("raylib");

pub const Enemy = struct {
    position: rl.Vector2,

    size: rl.Vector2 = .{
        .x = 80.0,
        .y = 80.0,
    },

    alive: bool = true,

    pub fn init(position: rl.Vector2) Enemy {
        return .{
            .position = position,
        };
    }

    pub fn getRectangle(self: Enemy) rl.Rectangle {
        return .{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
    }

    pub fn update(self: *Enemy, deltaTime: f32) void {
        _ = self;
        _ = deltaTime;

        // Noch nichts.
    }

    pub fn checkHitByAttack(self: *Enemy, attackRect: rl.Rectangle) void {
        if (!self.alive) return;

        if (rl.checkCollisionRecs(self.getRectangle(), attackRect)) {
            self.alive = false;
        }
    }

    pub fn draw(self: Enemy) void {
        if (!self.alive) return;

        rl.drawRectangleRec(
            self.getRectangle(),
            rl.Color.green,
        );
    }

    pub fn hit(self: *Enemy) void {
        self.alive = false;
    }
};
