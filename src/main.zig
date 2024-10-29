const rl = @import("raylib");
const rlight = @import("rlights.zig");

pub fn main() anyerror!void {
    rl.setConfigFlags(rl.ConfigFlags{
        .msaa_4x_hint = true,
    });

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

    rl.disableCursor();
    rl.setTargetFPS(60);

    const shader = rl.loadShader("resource/shader/lighting.vert", "resource/shader/lighting.frag");
    defer rl.unloadShader(shader);

    shader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_vector_view)] = rl.getShaderLocation(shader, "viewPos");
    shader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_matrix_model)] = rl.getShaderLocation(shader, "matModel");

    const ambientLoc = rl.getShaderLocation(shader, "ambient");
    const ambientLocValue = [_]f32{ 0.1, 0.1, 0.1, 1.0 };
    rl.setShaderValue(shader, ambientLoc, &ambientLocValue[0], rl.ShaderUniformDataType.shader_uniform_vec4);

    var lights = [_]rlight.Light{
        rlight.createLight(@intFromEnum(rlight.LightType.point), rl.Vector3{ .x = -2, .y = 1, .z = -2 }, rl.Vector3.zero(), rl.Color.yellow, shader),
        rlight.createLight(@intFromEnum(rlight.LightType.point), rl.Vector3{ .x = 2, .y = 1, .z = 2 }, rl.Vector3.zero(), rl.Color.red, shader),
        rlight.createLight(@intFromEnum(rlight.LightType.point), rl.Vector3{ .x = -2, .y = 1, .z = 2 }, rl.Vector3.zero(), rl.Color.green, shader),
        rlight.createLight(@intFromEnum(rlight.LightType.point), rl.Vector3{ .x = 2, .y = 1, .z = -2 }, rl.Vector3.zero(), rl.Color.blue, shader),
    };

    while (!rl.windowShouldClose()) {
        rl.updateCamera(&camera, rl.CameraMode.camera_orbital);

        const cameraPos = [_]f32{ camera.position.x, camera.position.y, camera.position.z };
        rl.setShaderValue(shader, shader.locs[@intFromEnum(rl.ShaderLocationIndex.shader_loc_vector_view)], &cameraPos[0], rl.ShaderUniformDataType.shader_uniform_vec3);

        if (rl.isKeyPressed(rl.KeyboardKey.key_y)) {
            lights[0].enabled = !lights[0].enabled;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
            lights[1].enabled = !lights[1].enabled;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_g)) {
            lights[2].enabled = !lights[2].enabled;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_b)) {
            lights[3].enabled = !lights[3].enabled;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_z)) {
            camera.target = rl.Vector3.zero();
        }

        for (0..lights.len) |i| {
            rlight.updateLightValues(shader, lights[i]);
        }

        {
            rl.beginDrawing();
            defer rl.endDrawing();

            rl.clearBackground(rl.Color.white);

            {
                rl.beginMode3D(camera);
                defer rl.endMode3D();

                {
                    rl.beginShaderMode(shader);
                    defer rl.endShaderMode();

                    rl.drawPlane(rl.Vector3.zero(), rl.Vector2{.x=10, .y=10}, rl.Color.white);
                    rl.drawCube(rl.Vector3.zero(), 2, 4, 2, rl.Color.white);
                }

                for (0..lights.len) |i| {
                    if (lights[i].enabled) {
                        rl.drawSphereEx(lights[i].position, 0.2, 8, 8, lights[i].color);
                    } else {
                        rl.drawSphereWires(lights[i].position, 0.2, 8, 8, lights[i].color);
                    }
                }
            }

            rl.drawFPS(10, 10);

            rl.drawText("Use keys [Y][R][G][B] to toggle lights", 10, 40, 20, rl.Color.dark_gray);
        }
    }
}
