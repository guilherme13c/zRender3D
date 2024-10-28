const rl = @import("raylib");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "zRender3D");
    defer rl.closeWindow();

    var camera = rl.Camera{
        .position = rl.Vector3{ .x = 5, .y = 5, .z = 5 },
        .target = rl.Vector3{ .x = 0, .y = 0, .z = 0 },
        .up = rl.Vector3{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45,
        .projection = rl.CameraProjection.camera_perspective,
    };

    const propPosition = rl.Vector3{ .x = 0, .y = 0, .z = 0 };

    rl.disableCursor();
    rl.setTargetFPS(60);

    const shader = rl.loadShader("resource/shader/lighting.vert", "resource/shader/lighting.frag");
    defer rl.unloadShader(shader);

    const lightPosLoc = rl.getShaderLocation(shader, "lightPos");
    const viewPosLoc = rl.getShaderLocation(shader, "viewPos");
    const lightColorLoc = rl.getShaderLocation(shader, "lightColor");
    const objectColorLoc = rl.getShaderLocation(shader, "objectColor");
    const modelLoc = rl.getShaderLocation(shader, "model");
    const viewLoc = rl.getShaderLocation(shader, "view");
    const projectionLoc = rl.getShaderLocation(shader, "projection");

    const lightPos = rl.Vector3{ .x = 5.0, .y = 5.0, .z = 5.0 };
    const viewPos = camera.position;
    const lightColor = rl.Vector3{ .x = 1.0, .y = 1.0, .z = 1.0 };
    const objectColor = rl.Vector3{ .x = 1.0, .y = 0.5, .z = 0.31 };

    rl.setShaderValue(shader, lightPosLoc, &lightPos, rl.ShaderUniformDataType.shader_uniform_vec3);
    rl.setShaderValue(shader, viewPosLoc, &viewPos, rl.ShaderUniformDataType.shader_uniform_vec3);
    rl.setShaderValue(shader, lightColorLoc, &lightColor, rl.ShaderUniformDataType.shader_uniform_vec3);
    rl.setShaderValue(shader, objectColorLoc, &objectColor, rl.ShaderUniformDataType.shader_uniform_vec3);

    while (!rl.windowShouldClose()) {
        rl.updateCamera(&camera, rl.CameraMode.camera_third_person);

        if (rl.isKeyPressed(rl.KeyboardKey.key_z)) {
            camera.target = rl.Vector3{ .x = 0, .y = 0, .z = 0 };
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        {
            rl.beginMode3D(camera);
            defer rl.endMode3D();

            const modelMatrix = rl.Matrix.translate(propPosition.x, propPosition.y, propPosition.z);
            const viewMatrix = rl.getCameraMatrix(camera);
            const projectionMatrix = rl.Matrix.perspective(45, screenWidth / screenHeight, 0.1, 100.0);

            rl.setShaderValueMatrix(shader, modelLoc, modelMatrix);
            rl.setShaderValueMatrix(shader, viewLoc, viewMatrix);
            rl.setShaderValueMatrix(shader, projectionLoc, projectionMatrix);

            {
                rl.beginShaderMode(shader);
                defer rl.endShaderMode();

                rl.drawCube(propPosition, 2, 2, 2, rl.Color.ray_white);
            }
        }
    }
}
