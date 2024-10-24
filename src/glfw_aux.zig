const c = @cImport({
    @cInclude("GL/glew.h");
    @cInclude("GLFW/glfw3.h");
});

const std = @import("std");

export fn errorCallback(err: c_int, description: [*c]const u8) callconv(.C) void {
    std.debug.panic("Error: {s} - {}\n", .{ description, err });
}

pub fn setupGLFW(window: *?*c.GLFWwindow, width: c_int, height: c_int) u8 {
    _ = c.glfwSetErrorCallback(errorCallback);

    if (c.glfwInit() == c.GL_FALSE) {
        std.debug.print("Failed to initialize GLFW\n", .{});
        return 1;
    }

    c.glfwWindowHint(c.GLFW_SAMPLES, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    window.* = c.glfwCreateWindow(width, height, "zRender3D", null, null);

    if (window.* == null) {
        std.debug.print("Failed to create GLFW window\n", .{});
        return 1;
    }

    c.glfwMakeContextCurrent(window.*);

    return 0;
}
