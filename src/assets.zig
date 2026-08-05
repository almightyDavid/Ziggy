const rl = @import("raylib");

pub const Assets = struct {
    player: rl.Texture2D,
    ground_enemy: rl.Texture2D,
    flying_enemy: rl.Texture2D,
    projectile: rl.Texture2D,

    grass: rl.Texture2D,
    dirt: rl.Texture2D,

    pub fn load() !Assets {
        return .{
            .player = try rl.loadTexture("src/assets/pictures/player.png"),
            .ground_enemy = try rl.loadTexture("src/assets/pictures/ground_enemy.png"),
            .flying_enemy = try rl.loadTexture("src/assets/pictures/flying_enemy.png"),
            .projectile = try rl.loadTexture("src/assets/pictures/projectile.png"),
            .grass = try rl.loadTexture("src/assets/pictures/grass.png"),
            .dirt = try rl.loadTexture("src/assets/pictures/dirt.png"),
        };
    }

    pub fn unload(self: Assets) void {
        rl.unloadTexture(self.player);
        rl.unloadTexture(self.ground_enemy);
        rl.unloadTexture(self.flying_enemy);
        rl.unloadTexture(self.projectile);
        rl.unloadTexture(self.grass);
        rl.unloadTexture(self.dirt);
    }
};
