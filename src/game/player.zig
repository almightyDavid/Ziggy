const rl = @import("raylib");
const Projectile = @import("projectile.zig").Projectile;
const Collider = @import("collision.zig").Collider;
const Assets = @import("../assets.zig").Assets;

pub const Player = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    direction: f32,
    health: i32,
    alive: bool,

    size: rl.Vector2 = .{
        .x = 32.0,
        .y = 64.0,
    },

    grounded: bool = false,
    projectiles: [maxProjectiles]Projectile = [_]Projectile{Projectile.empty()} ** maxProjectiles,
    shootCooldown: f32 = 0.0,
    hitCooldown: f32 = 0.0,
    knockbackTimer: f32 = 0.0,

    const maxProjectiles = 8;
    const moveSpeed: f32 = 360.0;
    const gravity: f32 = 1600.0;
    const jumpSpeed: f32 = 600.0;

    const acceleration: f32 = 3000.0;
    const deceleration: f32 = 5000.0;
    const turnAcceleration: f32 = 7200.0;

    const hitCooldownDuration: f32 = 1.0;
    const knockbackDuration: f32 = 0.2;
    const knockbackSpeed: f32 = 500.0;
    const knockbackJumpSpeed: f32 = 500;
    const knockbackFriction: f32 = 900.0;

    const flickerIntervall: f32 = 0.1;

    pub fn init(position: rl.Vector2) Player {
        return .{
            .position = position,
            .velocity = .{
                .x = 0.0,
                .y = 0.0,
            },
            .alive = true,
            .direction = 1.0,
            .health = 3,
            .projectiles = [_]Projectile{Projectile.empty()} ** maxProjectiles,
            .shootCooldown = 0.0,
            .hitCooldown = 0.0,
            .knockbackTimer = 0.0,
        };
    }

    pub fn getRectangle(self: Player) rl.Rectangle {
        return .{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
    }

    pub fn getCollider(self: Player) Collider {
        return .{ .rect = .{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        } };
    }

    pub fn getCenter(self: Player) rl.Vector2 {
        return .{
            .x = self.position.x + self.size.x / 2,
            .y = self.position.y + self.size.y / 2,
        };
    }

    pub fn projectilesSlice(self: *Player) []Projectile {
        return self.projectiles[0..];
    }

    pub fn update(
        self: *Player,
        deltaTime: f32,
        platforms: []const rl.Rectangle,
    ) void {
        self.hitCooldown = @max(0.0, self.hitCooldown - deltaTime);

        const inputLocked = self.knockbackTimer > 0.0;

        if (inputLocked) {
            self.knockbackTimer = @max(0.0, self.knockbackTimer - deltaTime);
            self.velocity.x = moveToward(self.velocity.x, 0.0, knockbackFriction * deltaTime);
        } else {
            self.handleInput(deltaTime, platforms);
        }

        // Positive Y moves downward in screen coordinates.
        self.velocity.y += gravity * deltaTime;

        self.moveHorizontal(deltaTime, platforms);
        self.moveVertical(deltaTime, platforms);

        if (self.shootCooldown > 0.0) {
            self.shootCooldown -= deltaTime;
        }

        if (rl.isKeyPressed(.k) and self.shootCooldown <= 0.0) {
            self.shoot();
            self.shootCooldown = 0.1;
        }

        for (&self.projectiles) |*projectile| {
            projectile.update(deltaTime);
        }
    }

    fn handleInput(self: *Player, deltaTime: f32, platforms: []const rl.Rectangle) void {
        var moveDir: f32 = 0.0;

        if (rl.isKeyDown(.a) or rl.isKeyDown(.left)) {
            moveDir -= 1.0;
        }

        if (rl.isKeyDown(.d) or rl.isKeyDown(.right)) {
            moveDir += 1.0;
        }

        if (moveDir != 0.0) {
            self.direction = moveDir;
        }

        const targetVelocityX = moveDir * moveSpeed;

        // safe?
        const reversing = moveDir != 0.0 and self.velocity.x * moveDir < 0.0;

        const movement: f32 = if (moveDir == 0.0) deceleration else if (reversing) turnAcceleration else acceleration;

        self.velocity.x = moveToward(self.velocity.x, targetVelocityX, movement * deltaTime);

        const jumpPressed =
            rl.isKeyPressed(.space) or
            rl.isKeyPressed(.w) or
            rl.isKeyPressed(.up);

        if (jumpPressed and self.grounded) {
            self.velocity.y = -jumpSpeed;
            self.grounded = false;
        }

        if (rl.isKeyPressed(.j)) {
            self.teleport(platforms);
        }
    }

    pub fn hit(self: *Player, damage: i32, sourceX: f32) void {
        if (!self.alive) return;
        if (self.hitCooldown > 0.0) return;

        self.health -= damage;
        self.hitCooldown = hitCooldownDuration;
        self.knockbackTimer = knockbackDuration;

        const direction: f32 = if (self.getCenter().x < sourceX) -1.0 else 1.0;

        self.velocity.x = direction * knockbackSpeed;
        self.velocity.y = -knockbackJumpSpeed;

        self.grounded = false;

        if (self.health <= 0) {
            self.health = 0;
            self.alive = false;
        }
    }

    fn moveToward(value: f32, target: f32, amount: f32) f32 {
        if (value < target) {
            return @min(value + amount, target);
        }

        if (value > target) {
            return @max(value - amount, target);
        }

        return target;
    }

    fn shoot(self: *Player) void {
        for (&self.projectiles) |*projectile| {
            if (projectile.active) continue;

            projectile.* = Projectile.spawn(
                self.getCenter(),
                self.direction,
            );

            return;
        }
    }

    fn teleport(self: *Player, platforms: []const rl.Rectangle) void {
        const teleportAmount: f32 = 200 * self.direction;
        const destination_pos: rl.Vector2 = .{
            .x = self.position.x + teleportAmount,
            .y = self.position.y,
        };

        const destination_rect: rl.Rectangle = .{
            .x = destination_pos.x,
            .y = destination_pos.y,
            .width = self.size.x,
            .height = self.size.y,
        };

        var final_x = destination_pos.x;
        var collided = false;

        for (platforms) |platform| {
            if (!rl.checkCollisionRecs(destination_rect, platform)) {
                continue;
            }

            collided = true;

            if (teleportAmount > 0.0) {
                // Teleporting right. Put player left of platform.
                const corrected_x = platform.x - self.size.x;

                if (corrected_x < final_x) {
                    final_x = corrected_x;
                }
            } else if (teleportAmount < 0.0) {
                // Teleporting left. Put player right of platform.
                const corrected_x = platform.x + platform.width;

                if (corrected_x > final_x) {
                    final_x = corrected_x;
                }
            }
        }

        self.position.x = final_x;
        self.velocity.x = 0.0;

        if (collided) {
            self.velocity.y = 0.0;
        }

        self.grounded = false;
    }

    fn moveHorizontal(
        self: *Player,
        deltaTime: f32,
        platforms: []const rl.Rectangle,
    ) void {
        self.position.x += self.velocity.x * deltaTime;

        for (platforms) |platform| {
            if (!rl.checkCollisionRecs(
                self.getRectangle(),
                platform,
            )) {
                continue;
            }

            if (self.velocity.x > 0.0) {
                // move right place player left
                self.position.x =
                    platform.x - self.size.x;
            } else if (self.velocity.x < 0.0) {
                // move left place player right
                self.position.x =
                    platform.x + platform.width;
            }

            self.velocity.x = 0.0;
        }
    }

    fn moveVertical(
        self: *Player,
        deltaTime: f32,
        platforms: []const rl.Rectangle,
    ) void {
        self.position.y += self.velocity.y * deltaTime;
        self.grounded = false;

        for (platforms) |platform| {
            if (!rl.checkCollisionRecs(
                self.getRectangle(),
                platform,
            )) {
                continue;
            }

            if (self.velocity.y > 0.0) {
                self.position.y =
                    platform.y - self.size.y;

                self.velocity.y = 0.0;
                self.grounded = true;
            } else if (self.velocity.y < 0.0) {
                self.position.y =
                    platform.y + platform.height;

                self.velocity.y = 0.0;
            }
        }
    }

    pub fn draw(self: Player, assets: *const Assets) void {
        const flicker = self.getDrawFlicker();

        const direction: f32 = if (self.direction < 0.0) -1.0 else 1.0;

        const textureWidth: f32 = @floatFromInt(assets.player.width);
        const textureHeight: f32 = @floatFromInt(assets.player.height);

        const source = rl.Rectangle{
            .x = 0.0,
            .y = 0.0,
            .width = textureWidth * direction,
            .height = textureHeight,
        };

        const spriteSize = rl.Vector2{
            .x = 64.0,
            .y = 64.0,
        };

        const destination = rl.Rectangle{
            .x = self.position.x - spriteSize.x / 5,
            .y = self.position.y + self.size.y - spriteSize.y,
            .width = spriteSize.x,
            .height = spriteSize.y,
        };

        rl.drawTexturePro(assets.player, source, destination, .{ .x = 0.0, .y = 0.0 }, 0.0, flicker);

        for (self.projectiles) |projectile| {
            projectile.draw(assets.projectile);
        }
    }

    fn getDrawFlicker(self: Player) rl.Color {
        var flickerColor = rl.Color.white;

        if (self.hitCooldown <= 0.0) {
            return flickerColor;
        }

        const elapsed = hitCooldownDuration - self.hitCooldown;
        const flickerPhase: u32 = @intFromFloat(elapsed / flickerIntervall);

        flickerColor.a = if (flickerPhase % 2 == 0) 70 else 255;

        return flickerColor;
    }
};
