const rl = @import("raylib");

pub const Renderer = struct {
    target: rl.RenderTexture2D,
    logicalWidth: f32,
    logicalHeight: f32,
    offsetX: f32,
    offsetY: f32,
    scale: f32,

    pub fn init(logical_width: i32, logical_height: i32) !Renderer {
        const logicalWidth: f32 = @floatFromInt(logical_width);
        const logicalHeight: f32 = @floatFromInt(logical_height);
        const target = try rl.loadRenderTexture(logical_width, logical_height);

        rl.setTextureFilter(target.texture, .bilinear);
        return Renderer{
            .target = target,
            .logicalWidth = logicalWidth,
            .logicalHeight = logicalHeight,
            .offsetX = 0.0,
            .offsetY = 0.0,
            .scale = 1.0,
        };
    }

    pub fn deinit(self: *Renderer) void {
        rl.unloadRenderTexture(self.target);
    }

    pub fn updateViewport(self: *Renderer) void {
        const screenWidth: f32 = @floatFromInt(rl.getScreenWidth());
        const screenHeight: f32 = @floatFromInt(rl.getScreenHeight());

        const logicalWidth: f32 = self.logicalWidth;
        const logicalHeight: f32 = self.logicalHeight;

        self.scale = @min(screenWidth / self.logicalWidth, screenHeight / self.logicalHeight);

        const destinationWidth: f32 = logicalWidth * self.scale;
        const destinationHeight: f32 = logicalHeight * self.scale;

        self.offsetX = (screenWidth - destinationWidth) / 2.0;
        self.offsetY = (screenHeight - destinationHeight) / 2.0;

        rl.setMouseOffset(
            @intFromFloat(-self.offsetX),
            @intFromFloat(-self.offsetY),
        );

        rl.setMouseScale(
            1.0 / self.scale,
            1.0 / self.scale,
        );
    }

    pub fn beginLogicalDrawing(self: *Renderer) void {
        self.updateViewport();

        rl.beginTextureMode(self.target);
        rl.clearBackground(rl.Color.black);
    }

    pub fn endLogicalDrawing(self: *Renderer) void {
        rl.endTextureMode();
        const screenWidth: f32 = @floatFromInt(rl.getScreenWidth());
        const screenHeight: f32 = @floatFromInt(rl.getScreenHeight());

        const scale = @min(screenWidth / self.logicalWidth, screenHeight / self.logicalHeight);

        const destinationWidth = self.logicalWidth * scale;
        const destinationHeight = self.logicalHeight * scale;

        const offsetX = (screenWidth - destinationWidth) / 2.0;
        const offsetY = (screenHeight - destinationHeight) / 2.0;

        rl.setMouseOffset(
            @intFromFloat(-offsetX),
            @intFromFloat(-offsetY),
        );

        rl.setMouseScale(
            1.0 / scale,
            1.0 / scale,
        );

        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);
        rl.drawTexturePro(
            self.target.texture,
            //gets rendered vertically flipped, compensating with -height
            .{ .x = 0, .y = 0, .width = self.logicalWidth, .height = -self.logicalHeight },
            .{ .x = offsetX, .y = offsetY, .width = destinationWidth, .height = destinationHeight },
            .{
                .x = 0.0,
                .y = 0.0,
            },
            0.0,
            rl.Color.white,
        );
        rl.endDrawing();
    }
};
