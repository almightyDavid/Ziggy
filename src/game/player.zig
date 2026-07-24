const rl = @import("raylib");
const Projectile = @import("projectile.zig").Projectile;

pub const Player = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    direction: f32,

    size: rl.Vector2 = .{
        .x = 40.0,
        .y = 56.0,
    },

    grounded: bool = false,
    projectiles: [maxProjectiles]Projectile = [_]Projectile{Projectile.empty()} ** maxProjectiles,
    shootCooldown: f32 = 0.0,

    const maxProjectiles = 8;
    const moveSpeed: f32 = 260.0;
    const gravity: f32 = 1600.0;
    const jumpSpeed: f32 = 600.0;

    pub fn init(position: rl.Vector2) Player {
        return .{
            .position = position,
            .velocity = .{
                .x = 0.0,
                .y = 0.0,
            },
            .direction = 1.0,
            .projectiles = [_]Projectile{Projectile.empty()} ** maxProjectiles,
            .shootCooldown = 0.0,
        };
    }

    pub fn getCollider(self: Player) rl.Rectangle {
        return .{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
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
        self.handleInput(platforms);

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

    fn handleInput(self: *Player, platforms: []const rl.Rectangle) void {
        var moveDir: f32 = 0.0;

        if (rl.isKeyDown(.a) or rl.isKeyDown(.left)) {
            moveDir -= 1.0;
        }

        if (rl.isKeyDown(.d) or rl.isKeyDown(.right)) {
            moveDir += 1.0;
        }

        self.velocity.x = moveDir * moveSpeed;

        if (moveDir != 0.0) {
            self.direction = moveDir;
        }

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
                self.getCollider(),
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
                self.getCollider(),
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

    pub fn draw(self: Player) void {
        rl.drawRectangleRec(
            self.getCollider(),
            rl.Color.blue,
        );

        for (self.projectiles) |projectile| {
            projectile.draw();
        }
    }
};
