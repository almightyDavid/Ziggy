const std = @import("std");
const rl = @import("raylib");
const Collider = @import("collision.zig").Collider;

pub const GroundEnemy = struct {
    position: rl.Vector2,
    velocity: rl.Vector2 = .{ .x = 0.0, .y = 0.0 },
    spawn_x: f32,
    direction: f32 = 1.0,
    size: rl.Vector2 = .{ .x = 48.0, .y = 56.0 },
    grounded: bool = false,
    alive: bool = true,
    health: i32 = 3,
    patrolDistance: f32 = 220.0,
    detectionRange: f32 = 520.0,
    jumpCooldown: f32 = 0.0,

    const maxHealth: i32 = 3;
    const patrolSpeed: f32 = 90.0;
    const chaseSpeed: f32 = 170.0;
    const gravity: f32 = 1600.0;
    const jumpSpeed: f32 = 590.0;

    pub fn init(position: rl.Vector2) GroundEnemy {
        return .{
            .position = position,
            .spawn_x = position.x,
        };
    }

    pub fn update(
        self: *GroundEnemy,
        deltaTime: f32,
        platforms: []const rl.Rectangle,
        player_center: rl.Vector2,
    ) void {
        if (!self.alive) return;

        self.jumpCooldown = @max(0.0, self.jumpCooldown - deltaTime);
        self.updateAI(platforms, player_center);

        self.velocity.y += gravity * deltaTime;
        self.moveHorizontal(deltaTime, platforms);
        self.moveVertical(deltaTime, platforms);
    }

    fn updateAI(
        self: *GroundEnemy,
        platforms: []const rl.Rectangle,
        player_center: rl.Vector2,
    ) void {
        const center = self.getCenter();
        const dx = player_center.x - center.x;
        const dy = player_center.y - center.y;
        const chasing = @abs(dx) <= self.detectionRange and @abs(dy) <= 280.0;

        if (chasing) {
            self.direction = if (dx < 0.0) -1.0 else 1.0;
            self.velocity.x = self.direction * chaseSpeed;

            const obstacle = self.wallAhead(platforms);
            const gap = !self.groundAhead(platforms);
            const player_above = dy < -55.0 and @abs(dx) < 240.0;

            if (self.grounded and self.jumpCooldown <= 0.0 and
                (obstacle or gap or player_above))
            {
                self.jump();
            }
        } else {
            const min_x = self.spawn_x - self.patrolDistance;
            const max_x = self.spawn_x + self.patrolDistance;

            if (self.position.x <= min_x) self.direction = 1.0;
            if (self.position.x + self.size.x >= max_x) self.direction = -1.0;

            // Beim Patrouillieren nicht blind in ein Loch springen.
            if (self.grounded and !self.groundAhead(platforms)) {
                self.direction *= -1.0;
            }

            if (self.grounded and self.jumpCooldown <= 0.0 and self.wallAhead(platforms)) {
                self.jump();
            }

            self.velocity.x = self.direction * patrolSpeed;
        }
    }

    fn jump(self: *GroundEnemy) void {
        self.velocity.y = -jumpSpeed;
        self.grounded = false;
        self.jumpCooldown = 0.35;
    }

    fn wallAhead(self: GroundEnemy, platforms: []const rl.Rectangle) bool {
        const sensor_width: f32 = 10.0;
        const sensor = rl.Rectangle{
            .x = if (self.direction > 0.0)
                self.position.x + self.size.x
            else
                self.position.x - sensor_width,
            .y = self.position.y + 8.0,
            .width = sensor_width,
            .height = self.size.y - 14.0,
        };

        for (platforms) |platform| {
            if (rl.checkCollisionRecs(sensor, platform)) return true;
        }
        return false;
    }

    fn groundAhead(self: GroundEnemy, platforms: []const rl.Rectangle) bool {
        const sensor_width: f32 = 12.0;
        const sensor = rl.Rectangle{
            .x = if (self.direction > 0.0)
                self.position.x + self.size.x + 4.0
            else
                self.position.x - sensor_width - 4.0,
            .y = self.position.y + self.size.y + 2.0,
            .width = sensor_width,
            .height = 34.0,
        };

        for (platforms) |platform| {
            if (rl.checkCollisionRecs(sensor, platform)) return true;
        }
        return false;
    }

    fn moveHorizontal(
        self: *GroundEnemy,
        deltaTime: f32,
        platforms: []const rl.Rectangle,
    ) void {
        self.position.x += self.velocity.x * deltaTime;

        // TODO: make universal movement.zig so the level doesnt care what shape it is
        // this rect is garbage but it will hold for now
        for (platforms) |platform| {
            const rect = rl.Rectangle{
                .x = self.position.x,
                .y = self.position.y,
                .width = self.size.x,
                .height = self.size.y,
            };

            if (!rl.checkCollisionRecs(rect, platform)) continue;

            if (self.velocity.x > 0.0) {
                self.position.x = platform.x - self.size.x;
            } else if (self.velocity.x < 0.0) {
                self.position.x = platform.x + platform.width;
            }
            self.velocity.x = 0.0;
        }
    }

    fn moveVertical(
        self: *GroundEnemy,
        deltaTime: f32,
        platforms: []const rl.Rectangle,
    ) void {
        self.position.y += self.velocity.y * deltaTime;
        self.grounded = false;

        // TODO: make universal movement.zig so the level doesnt care what shape it is and what enemy
        // this rect is garbage but it will hold for now
        for (platforms) |platform| {
            const rect = rl.Rectangle{
                .x = self.position.x,
                .y = self.position.y,
                .width = self.size.x,
                .height = self.size.y,
            };

            if (!rl.checkCollisionRecs(rect, platform)) continue;

            if (self.velocity.y > 0.0) {
                self.position.y = platform.y - self.size.y;
                self.velocity.y = 0.0;
                self.grounded = true;
            } else if (self.velocity.y < 0.0) {
                self.position.y = platform.y + platform.height;
                self.velocity.y = 0.0;
            }
        }
    }

    pub fn getCollider(self: GroundEnemy) Collider {
        return .{ .rect = .{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        } };
    }

    // TODO: make it work for Collider
    pub fn getCenter(self: GroundEnemy) rl.Vector2 {
        return .{
            .x = self.position.x + self.size.x * 0.5,
            .y = self.position.y + self.size.y * 0.5,
        };
    }

    pub fn hit(self: *GroundEnemy, damage: i32) void {
        if (!self.alive) return;
        self.health -= damage;
        if (self.health <= 0) {
            self.health = 0;
            self.alive = false;
        }
    }

    // TODO: replace drawRectangleRec
    pub fn draw(self: GroundEnemy, texture: rl.Texture2D) void {
        if (!self.alive) return;

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
        drawHealthBar(self.position, self.size.x, self.health, maxHealth);
    }
};

pub const FlyingEnemy = struct {
    position: rl.Vector2,
    velocity: rl.Vector2 = .{ .x = 0.0, .y = 0.0 },
    spawn_position: rl.Vector2,
    time_alive: f32 = 0.0,
    alive: bool = true,
    size: rl.Vector2 = .{ .x = 52.0, .y = 40.0 },
    health: i32 = 2,
    detectionRange: f32 = 600.0,
    patrol_radius: f32 = 150.0,

    const maxHealth: i32 = 2;
    const chaseSpeed: f32 = 145.0;

    pub fn init(position: rl.Vector2) FlyingEnemy {
        return .{
            .position = position,
            .spawn_position = position,
        };
    }

    pub fn update(
        self: *FlyingEnemy,
        deltaTime: f32,
        player_center: rl.Vector2,
    ) void {
        if (!self.alive) return;
        self.time_alive += deltaTime;

        const center = self.getCenter();
        const to_player = rl.Vector2{
            .x = player_center.x - center.x,
            .y = player_center.y - center.y,
        };
        const distanceSquared = to_player.x * to_player.x + to_player.y * to_player.y;

        if (distanceSquared <= self.detectionRange * self.detectionRange) {
            const distance = @sqrt(distanceSquared);
            if (distance > 0.001) {
                self.velocity = .{
                    .x = to_player.x / distance * chaseSpeed,
                    .y = to_player.y / distance * chaseSpeed,
                };
            }
        } else {
            // Elliptische Flugbahn um den Spawnpunkt.
            const target = rl.Vector2{
                .x = self.spawn_position.x + std.math.cos(self.time_alive * 0.9) * self.patrol_radius,
                .y = self.spawn_position.y + std.math.sin(self.time_alive * 1.4) * 70.0,
            };
            self.velocity = .{
                .x = (target.x - self.position.x) * 2.0,
                .y = (target.y - self.position.y) * 2.0,
            };
        }

        self.position.x += self.velocity.x * deltaTime;
        self.position.y += self.velocity.y * deltaTime;
    }

    pub fn getCollider(self: FlyingEnemy) Collider {
        return .{ .rect = .{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        } };
    }

    // TODO: make it work for Collider
    pub fn getCenter(self: FlyingEnemy) rl.Vector2 {
        return .{
            .x = self.position.x + self.size.x * 0.5,
            .y = self.position.y + self.size.y * 0.5,
        };
    }

    pub fn hit(self: *FlyingEnemy, damage: i32) void {
        if (!self.alive) return;
        self.health -= damage;
        if (self.health <= 0) {
            self.health = 0;
            self.alive = false;
        }
    }

    pub fn draw(self: FlyingEnemy, texture: rl.Texture2D) void {
        if (!self.alive) return;

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
        drawHealthBar(self.position, self.size.x, self.health, maxHealth);
    }
};

fn drawHealthBar(
    position: rl.Vector2,
    width: f32,
    health: i32,
    maxHealth: i32,
) void {
    const bar_height: f32 = 7.0;
    const y = position.y - 13.0;
    const ratio = @as(f32, @floatFromInt(health)) /
        @as(f32, @floatFromInt(maxHealth));

    rl.drawRectangleRec(.{
        .x = position.x,
        .y = y,
        .width = width,
        .height = bar_height,
    }, rl.Color.dark_gray);

    rl.drawRectangleRec(.{
        .x = position.x + 1.0,
        .y = y + 1.0,
        .width = (width - 2.0) * ratio,
        .height = bar_height - 2.0,
    }, rl.Color.lime);
}
