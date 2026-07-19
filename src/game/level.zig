const rl = @import("raylib");
const enemies_mod = @import("enemy_ai.zig");
const GroundEnemy = enemies_mod.GroundEnemy;
const FlyingEnemy = enemies_mod.FlyingEnemy;

pub const levelWidth: f32 = 10000;
pub const levelHeight: f32 = 2000;

pub const platforms = [_]rl.Rectangle{
    // =========================================================
    // Start area
    // =========================================================
    .{
        .x = 0.0,
        .y = 550.0,
        .width = 800.0,
        .height = 50.0,
    },

    .{
        .x = 180.0,
        .y = 450.0,
        .width = 180.0,
        .height = 25.0,
    },
    .{
        .x = 430.0,
        .y = 370.0,
        .width = 170.0,
        .height = 25.0,
    },
    .{
        .x = 650.0,
        .y = 285.0,
        .width = 100.0,
        .height = 25.0,
    },

    // Tall wall to test horizontal collision and teleport correction.
    .{
        .x = 760.0,
        .y = 150.0,
        .width = 40.0,
        .height = 400.0,
    },

    // =========================================================
    // Gap after first area
    // =========================================================
    .{
        .x = 950.0,
        .y = 550.0,
        .width = 500.0,
        .height = 50.0,
    },

    .{
        .x = 1050.0,
        .y = 470.0,
        .width = 120.0,
        .height = 20.0,
    },
    .{
        .x = 1240.0,
        .y = 410.0,
        .width = 120.0,
        .height = 20.0,
    },

    // =========================================================
    // Stair test
    // =========================================================
    .{
        .x = 1600.0,
        .y = 520.0,
        .width = 120.0,
        .height = 30.0,
    },
    .{
        .x = 1740.0,
        .y = 480.0,
        .width = 120.0,
        .height = 30.0,
    },
    .{
        .x = 1880.0,
        .y = 440.0,
        .width = 120.0,
        .height = 30.0,
    },
    .{
        .x = 2020.0,
        .y = 400.0,
        .width = 120.0,
        .height = 30.0,
    },

    // Ground below stairs.
    .{
        .x = 1500.0,
        .y = 650.0,
        .width = 900.0,
        .height = 50.0,
    },

    // =========================================================
    // Ceiling / tunnel test
    // =========================================================
    .{
        .x = 2600.0,
        .y = 600.0,
        .width = 900.0,
        .height = 50.0,
    },

    // Ceiling
    .{
        .x = 2700.0,
        .y = 360.0,
        .width = 500.0,
        .height = 30.0,
    },

    // Left wall of tunnel
    .{
        .x = 2700.0,
        .y = 390.0,
        .width = 30.0,
        .height = 210.0,
    },

    // Right wall of tunnel
    .{
        .x = 3170.0,
        .y = 390.0,
        .width = 30.0,
        .height = 210.0,
    },

    // Small platform inside tunnel
    .{
        .x = 2880.0,
        .y = 500.0,
        .width = 140.0,
        .height = 20.0,
    },

    // =========================================================
    // Thin platform precision jumps
    // =========================================================
    .{
        .x = 3700.0,
        .y = 560.0,
        .width = 300.0,
        .height = 40.0,
    },
    .{
        .x = 4100.0,
        .y = 500.0,
        .width = 80.0,
        .height = 15.0,
    },
    .{
        .x = 4300.0,
        .y = 450.0,
        .width = 70.0,
        .height = 15.0,
    },
    .{
        .x = 4500.0,
        .y = 400.0,
        .width = 60.0,
        .height = 15.0,
    },
    .{
        .x = 4700.0,
        .y = 470.0,
        .width = 90.0,
        .height = 15.0,
    },

    // Landing platform
    .{
        .x = 4950.0,
        .y = 560.0,
        .width = 400.0,
        .height = 40.0,
    },

    // =========================================================
    // Teleport correction test area
    // =========================================================
    .{
        .x = 5600.0,
        .y = 600.0,
        .width = 900.0,
        .height = 50.0,
    },

    // Wall directly in front of player path.
    .{
        .x = 5900.0,
        .y = 420.0,
        .width = 40.0,
        .height = 180.0,
    },

    // Another wall to test teleporting left/right around obstacles.
    .{
        .x = 6200.0,
        .y = 350.0,
        .width = 50.0,
        .height = 250.0,
    },

    // Platform above wall
    .{
        .x = 6050.0,
        .y = 300.0,
        .width = 300.0,
        .height = 25.0,
    },

    // =========================================================
    // Tall vertical camera test
    // =========================================================
    .{
        .x = 6900.0,
        .y = 800.0,
        .width = 700.0,
        .height = 50.0,
    },
    .{
        .x = 7000.0,
        .y = 700.0,
        .width = 120.0,
        .height = 20.0,
    },
    .{
        .x = 7200.0,
        .y = 600.0,
        .width = 120.0,
        .height = 20.0,
    },
    .{
        .x = 7400.0,
        .y = 500.0,
        .width = 120.0,
        .height = 20.0,
    },
    .{
        .x = 7200.0,
        .y = 400.0,
        .width = 120.0,
        .height = 20.0,
    },
    .{
        .x = 7000.0,
        .y = 300.0,
        .width = 120.0,
        .height = 20.0,
    },

    // Small ceiling near top to test upward collision.
    .{
        .x = 6900.0,
        .y = 180.0,
        .width = 700.0,
        .height = 30.0,
    },

    // =========================================================
    // Long final ground section
    // =========================================================
    .{
        .x = 8000.0,
        .y = 550.0,
        .width = 1400.0,
        .height = 50.0,
    },

    // Random blocks on final ground.
    .{
        .x = 8300.0,
        .y = 500.0,
        .width = 80.0,
        .height = 50.0,
    },
    .{
        .x = 8550.0,
        .y = 470.0,
        .width = 120.0,
        .height = 80.0,
    },
    .{
        .x = 8850.0,
        .y = 430.0,
        .width = 60.0,
        .height = 120.0,
    },

    // Final high platform.
    .{
        .x = 9200.0,
        .y = 350.0,
        .width = 350.0,
        .height = 30.0,
    },
};

pub const initialGroundEnemies = [_]GroundEnemy{
    GroundEnemy.init(.{ .x = 500.0, .y = 300.0 }),
    GroundEnemy.init(.{ .x = 1100.0, .y = 350.0 }),
    GroundEnemy.init(.{ .x = 8300.0, .y = 380.0 }),
};

pub const initialFlyingEnemies = [_]FlyingEnemy{
    FlyingEnemy.init(.{ .x = 1350.0, .y = 250.0 }),
    FlyingEnemy.init(.{ .x = 3000.0, .y = 260.0 }),
};

pub var ground_enemies = initialGroundEnemies;
pub var flying_enemies = initialFlyingEnemies;

pub fn reset() void {
    ground_enemies = initialGroundEnemies;
    flying_enemies = initialFlyingEnemies;
}

pub fn checkAttackHits(attack_rect: rl.Rectangle) void {
    for (&ground_enemies) |*enemy| enemy.checkHitByAttack(attack_rect);
    for (&flying_enemies) |*enemy| enemy.checkHitByAttack(attack_rect);
}

pub fn update(deltaTime: f32, player_center: rl.Vector2) void {
    for (&ground_enemies) |*enemy| {
        enemy.update(deltaTime, platforms[0..], player_center);
    }
    for (&flying_enemies) |*enemy| {
        enemy.update(deltaTime, player_center);
    }
}

pub fn draw() void {
    for (platforms) |platform| {
        rl.drawRectangleRec(platform, rl.Color.dark_gray);
    }
    for (ground_enemies) |enemy| enemy.draw();
    for (flying_enemies) |enemy| enemy.draw();
}
