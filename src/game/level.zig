const rl = @import("raylib");
const enemies_mod = @import("enemy_ai.zig");
const Projectile = @import("projectile.zig").Projectile;
const Player = @import("player.zig").Player;
const GroundEnemy = enemies_mod.GroundEnemy;
const FlyingEnemy = enemies_mod.FlyingEnemy;
const Assets = @import("../assets.zig").Assets;

pub const initialGroundEnemies = [_]GroundEnemy{
    GroundEnemy.init(.{ .x = 500.0, .y = 300.0 }),
    GroundEnemy.init(.{ .x = 1100.0, .y = 350.0 }),
    GroundEnemy.init(.{ .x = 2400.0, .y = 380.0 }),
};

pub const initialFlyingEnemies = [_]FlyingEnemy{
    FlyingEnemy.init(.{ .x = 1350.0, .y = 250.0 }),
    FlyingEnemy.init(.{ .x = 2200.0, .y = 260.0 }),
};

pub var groundEnemies = initialGroundEnemies;
pub var flyingEnemies = initialFlyingEnemies;

pub fn reset() void {
    groundEnemies = initialGroundEnemies;
    flyingEnemies = initialFlyingEnemies;
}

fn damagePlayerFromEnemyGroup(player: *Player, enemies: anytype) bool {
    for (enemies) |*enemy| {
        if (!enemy.alive) continue;

        if (!player.getCollider().intersects(enemy.getCollider())) {
            continue;
        }

        player.hit(1, enemy.getCenter().x);

        return true;
    }
    return false;
}

pub fn resolvePlayerEnemyCollisions(player: *Player) void {
    if (!player.alive) return;
    if (player.hitCooldown > 0.0) return;

    if (damagePlayerFromEnemyGroup(
        player,
        groundEnemies[0..],
    )) {
        // no double damage from overlapping enemies
        return;
    }

    _ = damagePlayerFromEnemyGroup(
        player,
        flyingEnemies[0..],
    );
}

fn hitEnemyGroup(projectile: *Projectile, enemies: anytype) bool {
    for (enemies) |*enemy| {
        if (!enemy.alive) continue;

        if (!projectile.getCollider().intersects(enemy.getCollider())) {
            continue;
        }

        enemy.hit(projectile.damage);
        projectile.deactivate();

        return true;
    }

    return false;
}

pub fn resolveProjectileCollision(
    projectile: *Projectile,
    platforms: []const rl.Rectangle,
    level_width: f32,
) void {
    if (!projectile.active) return;

    if (hitEnemyGroup(
        projectile,
        groundEnemies[0..],
    )) {
        return;
    }

    if (hitEnemyGroup(
        projectile,
        flyingEnemies[0..],
    )) {
        return;
    }

    // Platforms block projectiles.
    for (platforms) |platform| {
        if (!projectile.getCollider().intersects(
            .{ .rect = platform },
        )) {
            continue;
        }

        projectile.deactivate();
        return;
    }

    if (projectile.isOut(level_width)) {
        projectile.deactivate();
        return;
    }
}

pub fn update(
    deltaTime: f32,
    player: *Player,
    platforms: []const rl.Rectangle,
) void {
    const playerCenter = player.getCenter();
    for (&groundEnemies) |*enemy| {
        enemy.update(deltaTime, platforms, playerCenter);
    }
    for (&flyingEnemies) |*enemy| {
        enemy.update(deltaTime, playerCenter);
    }
    resolvePlayerEnemyCollisions(player);
}

pub fn draw(assets: *const Assets) void {
    for (groundEnemies) |enemy| enemy.draw(assets.ground_enemy);
    for (flyingEnemies) |enemy| enemy.draw(assets.flying_enemy);
}
