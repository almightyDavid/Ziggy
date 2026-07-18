const rl = @import("raylib");
const rg = @import("raygui");

const definitions = @import("../app_definitions.zig");

pub const MenuButton = struct {
    label: [:0]const u8,
    bounds: rl.Rectangle,
    action: definitions.Screen, // TODO: WEG DAMIT

    pub fn initCentered(label: [:0]const u8, centerX: f32, y: f32, action: definitions.Screen) MenuButton {
        const width = 200;
        const height = 60;

        return .{
            .label = label,
            .bounds = .{
                .x = centerX - width / 2,
                .y = y,
                .width = width,
                .height = height,
            },
            .action = action,
        };
    }

    pub fn draw(self: MenuButton, selected: bool) bool {
        const pressed = rg.button(self.bounds, self.label);

        if (selected) {
            const highlight_bounds = rl.Rectangle{
                .x = self.bounds.x - 3.0,
                .y = self.bounds.y - 3.0,
                .width = self.bounds.width + 6.0,
                .height = self.bounds.height + 6.0,
            };

            rl.drawRectangleLinesEx(
                highlight_bounds,
                3.0,
                rl.Color.yellow,
            );
        }

        return pressed;
    }

    pub fn isHovered(self: MenuButton, mousePosition: rl.Vector2) bool {
        return rl.checkCollisionPointRec(
            mousePosition,
            self.bounds,
        );
    }
};
