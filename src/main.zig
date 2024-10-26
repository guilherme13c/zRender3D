const rl = @import("raylib");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "zRender3D");
    defer rl.closeWindow();

    var camera = rl.Camera{
        .position = rl.Vector3{ .x = 10, .y = 10, .z = 10 },
        .target = rl.Vector3{ .x = 0, .y = 0, .z = 0 },
        .up = rl.Vector3{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45,
        .projection = rl.CameraProjection.camera_perspective,
    };

    const propPosition = rl.Vector3{ .x = 0, .y = 0, .z = 0 };

    rl.disableCursor();
    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.updateCamera(&camera, rl.CameraMode.camera_free);

        if (rl.isKeyPressed(rl.KeyboardKey.key_z)) camera.target = rl.Vector3{ .x = 0, .y = 0, .z = 0 };

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        {
            rl.beginMode3D(camera);
            defer rl.endMode3D();

            rl.drawCube(propPosition, 2, 2, 2, rl.Color.ray_white);
            rl.drawCubeWires(propPosition, 2, 2, 2, rl.Color.magenta);
        }
    }
}
