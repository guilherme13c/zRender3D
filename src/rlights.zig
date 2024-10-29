const rl = @import("raylib");

pub const Light = struct {
    typ: c_int,
    enabled: bool,
    position: rl.Vector3,
    target: rl.Vector3,
    color: rl.Color,
    attenuation: f32,

    // Shader locations
    enabledLoc: c_int,
    typeLoc: c_int,
    positionLoc: c_int,
    targetLoc: c_int,
    colorLoc: c_int,
    attenuationLoc: c_int,
};

pub const LightType = enum(c_int) {
    directional = 0,
    point,
};

var lightsCount: usize = 0;

pub fn createLight(typ: c_int, position: rl.Vector3, target: rl.Vector3, color: rl.Color, shader: rl.Shader) Light {
    var light = Light{
        .typ = typ,
        .enabled = false,
        .position = position,
        .target = target,
        .color = color,
        .attenuation = 0.0, // Or an initial default value
        .enabledLoc = 0,
        .typeLoc = 0,
        .positionLoc = 0,
        .targetLoc = 0,
        .colorLoc = 0,
        .attenuationLoc = 0,
    };

    light.enabled = true;
    light.enabledLoc = rl.getShaderLocation(shader, rl.textFormat("lights[%d].enabled", .{lightsCount}));
    light.typeLoc = rl.getShaderLocation(shader, rl.textFormat("lights[%d].type", .{lightsCount}));
    light.positionLoc = rl.getShaderLocation(shader, rl.textFormat("lights[%d].position", .{lightsCount}));
    light.targetLoc = rl.getShaderLocation(shader, rl.textFormat("lights[%d].target", .{lightsCount}));
    light.colorLoc = rl.getShaderLocation(shader, rl.textFormat("lights[%d].color", .{lightsCount}));

    updateLightValues(shader, light);
    lightsCount += 1;

    return light;
}

pub fn updateLightValues(shader: rl.Shader, light: Light) void {
    rl.setShaderValue(shader, light.enabledLoc, &light.enabled, rl.ShaderUniformDataType.shader_uniform_int);
    rl.setShaderValue(shader, light.typeLoc, &light.typ, rl.ShaderUniformDataType.shader_uniform_int);

    const position = [_]f32{ light.position.x, light.position.y, light.position.z };
    rl.setShaderValue(shader, light.positionLoc, &position, rl.ShaderUniformDataType.shader_uniform_vec3);

    const target = [_]f32{ light.target.x, light.target.y, light.target.z };
    rl.setShaderValue(shader, light.targetLoc, &target, rl.ShaderUniformDataType.shader_uniform_vec3);

    const color = [_]f32{
        @as(f32, @floatFromInt(light.color.r)) / 255.0,
        @as(f32, @floatFromInt(light.color.g)) / 255.0,
        @as(f32, @floatFromInt(light.color.b)) / 255.0,
        @as(f32, @floatFromInt(light.color.a)) / 255.0,
    };
    rl.setShaderValue(shader, light.colorLoc, &color, rl.ShaderUniformDataType.shader_uniform_vec4);
}
