const std = @import("std");
const rl = @import("raylib");

const Assets = @import("../assets.zig").Assets;

// Because this file is src/game/tiled_map.zig, this path points to:
// src/assets/levels/level1.tmj
const level_json = @embedFile("../assets/levels/level1.tmj");

// Only describe the JSON fields the game currently uses.
// Everything else written by Tiled is ignored during parsing.
const TiledLayerJson = struct {
    name: []const u8 = "",
    type: []const u8,
    width: u32 = 0,
    height: u32 = 0,
    data: ?[]const u32 = null,
};

const TiledMapJson = struct {
    width: u32,
    height: u32,
    tilewidth: u32,
    tileheight: u32,
    layers: []const TiledLayerJson,
};

pub const TiledMap = struct {
    allocator: std.mem.Allocator,

    width: f32,
    height: f32,

    columns: usize,
    rows: usize,
    tileWidth: u32,
    tileHeight: u32,

    tiles: []u32,

    platforms: []rl.Rectangle,

    pub fn init(allocator: std.mem.Allocator) !TiledMap {
        const parsed = try std.json.parseFromSlice(
            TiledMapJson,
            allocator,
            level_json,
            .{
                .ignore_unknown_fields = true,
            },
        );
        defer parsed.deinit();

        const map = parsed.value;

        const tile_layer = blk: {
            for (map.layers) |layer| {
                if (std.mem.eql(u8, layer.type, "tilelayer")) {
                    break :blk layer;
                }
            }

            return error.NoTileLayer;
        };

        const layer_data =
            tile_layer.data orelse return error.TileLayerHasNoData;

        const columns: usize = @intCast(map.width);
        const rows: usize = @intCast(map.height);

        if (layer_data.len != columns * rows) {
            return error.InvalidTileCount;
        }

        const tiles = try allocator.dupe(u32, layer_data);
        errdefer allocator.free(tiles);

        const platforms = try buildPlatforms(
            allocator,
            tiles,
            columns,
            rows,
            map.tilewidth,
            map.tileheight,
        );
        errdefer allocator.free(platforms);

        const width: f32 = @floatFromInt(map.width * map.tilewidth);
        const height: f32 = @floatFromInt(map.height * map.tileheight);

        return .{
            .allocator = allocator,
            .width = width,
            .height = height,
            .columns = columns,
            .rows = rows,
            .tileWidth = map.tilewidth,
            .tileHeight = map.tileheight,
            .tiles = tiles,
            .platforms = platforms,
        };
    }

    pub fn deinit(self: *TiledMap) void {
        self.allocator.free(self.tiles);
        self.allocator.free(self.platforms);
    }

    pub fn draw(self: *const TiledMap, assets: *const Assets) void {
        const tile_width_f: f32 = @floatFromInt(self.tileWidth);
        const tile_height_f: f32 = @floatFromInt(self.tileHeight);

        for (self.tiles, 0..) |raw_gid, index| {
            const gid = cleanGid(raw_gid);
            if (gid == 0) continue;

            const texture = switch (gid) {
                1 => assets.grass,
                2 => assets.dirt,
                else => continue,
            };

            const column = index % self.columns;
            const row = index / self.columns;

            const column_f: f32 = @floatFromInt(column);
            const row_f: f32 = @floatFromInt(row);
            const texture_width: f32 = @floatFromInt(texture.width);
            const texture_height: f32 = @floatFromInt(texture.height);

            const source = rl.Rectangle{
                .x = 0.0,
                .y = 0.0,
                .width = texture_width,
                .height = texture_height,
            };

            const destination = rl.Rectangle{
                .x = column_f * tile_width_f,
                .y = row_f * tile_height_f,
                .width = tile_width_f,
                .height = tile_height_f,
            };

            rl.drawTexturePro(
                texture,
                source,
                destination,
                .{ .x = 0.0, .y = 0.0 },
                0.0,
                rl.Color.white,
            );
        }
    }
};

fn cleanGid(gid: u32) u32 {
    return gid & 0x0fffffff;
}

fn isSolid(gid: u32) bool {
    return switch (cleanGid(gid)) {
        1, 2 => true,
        else => false,
    };
}

//horizontal first
fn countPlatformRuns(
    tiles: []const u32,
    columns: usize,
    rows: usize,
) usize {
    var count: usize = 0;
    var row: usize = 0;

    while (row < rows) : (row += 1) {
        var column: usize = 0;

        while (column < columns) {
            if (!isSolid(tiles[row * columns + column])) {
                column += 1;
                continue;
            }

            count += 1;

            while (column < columns and
                isSolid(tiles[row * columns + column]))
            {
                column += 1;
            }
        }
    }

    return count;
}

fn buildPlatforms(
    allocator: std.mem.Allocator,
    tiles: []const u32,
    columns: usize,
    rows: usize,
    tile_width: u32,
    tile_height: u32,
) ![]rl.Rectangle {
    const run_count = countPlatformRuns(tiles, columns, rows);
    const platforms = try allocator.alloc(rl.Rectangle, run_count);
    errdefer allocator.free(platforms);

    const tile_width_f: f32 = @floatFromInt(tile_width);
    const tile_height_f: f32 = @floatFromInt(tile_height);

    var platform_index: usize = 0;
    var row: usize = 0;

    while (row < rows) : (row += 1) {
        var column: usize = 0;

        while (column < columns) {
            if (!isSolid(tiles[row * columns + column])) {
                column += 1;
                continue;
            }

            const start_column = column;

            while (column < columns and
                isSolid(tiles[row * columns + column]))
            {
                column += 1;
            }

            const run_length = column - start_column;
            const start_column_f: f32 = @floatFromInt(start_column);
            const row_f: f32 = @floatFromInt(row);
            const run_length_f: f32 = @floatFromInt(run_length);

            platforms[platform_index] = .{
                .x = start_column_f * tile_width_f,
                .y = row_f * tile_height_f,
                .width = run_length_f * tile_width_f,
                .height = tile_height_f,
            };

            platform_index += 1;
        }
    }

    return platforms;
}
