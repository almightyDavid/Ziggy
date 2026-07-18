const rl = @import("raylib");
const ui = @import("ui_definitions.zig");

pub fn updateSelection(selectedIndex: *usize, buttonCount: usize) void {
    if (buttonCount == 0) return;

    if (rl.isKeyPressed(.j)) {
        selectedIndex.* = (selectedIndex.* + 1) % buttonCount;
    }

    if (rl.isKeyPressed(.k)) {
        selectedIndex.* = (selectedIndex.* + buttonCount - 1) % buttonCount;
    }
}

pub fn updateSelectionFromMouse(selectedIndex: *usize, buttons: []const ui.MenuButton) void {
    const mousePosition = rl.getMousePosition();
    const mouseDelta = rl.getMouseDelta();

    const mouseMoved = mouseDelta.x != 0.0 or mouseDelta.y != 0.0;
    for (buttons, 0..) |button, index| {
        const hovered = button.isHovered(mousePosition);

        if (mouseMoved and hovered) {
            selectedIndex.* = index;
            return;
        }
    }
}

pub fn activatePressed() bool {
    return rl.isKeyPressed(.enter) or rl.isKeyPressed(.space);
}
