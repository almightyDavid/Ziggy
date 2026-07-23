const rl = @import("raylib");

pub const Circle = struct {
    center: rl.Vector2,
    radius: f32,
};

pub const Collider = union(enum) {
    rect: rl.Rectangle,
    circle: Circle,

    pub fn intersects(a: Collider, b: Collider) bool {
        return switch (a) {
            .rect => |aRect| switch (b) {
                .rect => |bRect| {
                    return rl.checkCollisionRecs(aRect, bRect);
                },

                .circle => |bCircle| {
                    return rl.checkCollisionCircleRec(bCircle.center, bCircle.radius, aRect);
                },
            },

            .circle => |aCircle| switch (b) {
                .rect => |bRect| {
                    return rl.checkCollisionCircleRec(aCircle.center, aCircle.radius, bRect);
                },

                .circle => |bCircle| {
                    return rl.checkCollisionCircles(aCircle.center, aCircle.radius, bCircle.center, bCircle.radius);
                },
            },
        };
    }

    pub fn drawDebug(self: Collider, color: rl.Color) void {
        switch (self) {
            .rect => |rect| {
                rl.drawRectangleLinesEx(rect, 2.0, color);
            },

            .circle => |circle| {
                rl.drawCircleLinesV(circle.center, circle.radius, color);
            },
        }
    }
};
