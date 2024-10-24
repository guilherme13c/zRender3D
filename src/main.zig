const c = @cImport({
    @cInclude("GL/glew.h");
    @cInclude("GLFW/glfw3.h");
    // @cInclude("glm/glm.hpp");
});

const std = @import("std");
const glfw_aux = @import("glfw_aux.zig");

fn loadShaders(vertexShaderFilePath: []const u8, fragmentShaderFilePath: []const u8) c.GLuint {
    const vertexShaderId = c.glCreateShader(vertexShaderFilePath);
    const fragmentShaderId = c.glCreateShader(fragmentShaderFilePath);

    const allocator = std.heap.page_allocator;

    const vertexShaderFile = try std.fs.cwd().openFile(vertexShaderFilePath, .{});
    defer vertexShaderFile.close();

    const vertexShader = try vertexShaderFile.readToEndAlloc(allocator, std.math.maxInt(usize));

    const fragmentShaderFile = try std.fs.cwd().openFile(fragmentShaderFilePath, .{});
    defer fragmentShaderFile.close();

    const fragmentShader = try fragmentShaderFile.readToEndAlloc(allocator, std.math.maxInt(usize));

    var result = c.GL_FALSE;
    var infoLogLength = 0;

    const vertexShaderSourcePointer = vertexShader.ptr;
    c.glShaderSource(vertexShaderId, 1, &vertexShaderSourcePointer, null);
    c.glCompileShader(vertexShaderId);
    c.glGetShaderiv(vertexShaderId, c.GL_COMPILE_STATUS, &result);
    c.glGetShaderiv(vertexShaderId, c.GL_INFO_LOG_LENGTH, &infoLogLength);
    if (infoLogLength > 0) {
        const errorMessage = std.heap.page_allocator.alloc(u8, infoLogLength + 1) catch return;
        defer std.heap.page_allocator.free(errorMessage);

        c.glGetShaderInfoLog(vertexShaderId, infoLogLength, null, errorMessage.ptr);

        std.debug.print("{s}\n", .{errorMessage});
    }

    const fragmentShaderSourcePointer = fragmentShader.ptr;
    c.glShaderSource(fragmentShaderId, 1, &fragmentShaderSourcePointer, null);
    c.glCompileShader(fragmentShaderId);
    c.glGetShaderiv(fragmentShaderId, c.GL_COMPILE_STATUS, &result);
    c.glGetShaderiv(fragmentShaderId, c.GL_INFO_LOG_LENGTH, &infoLogLength);
    if (infoLogLength > 0) {
        const errorMessage = std.heap.page_allocator.alloc(u8, infoLogLength + 1) catch return;
        defer std.heap.page_allocator.free(errorMessage);

        c.glGetShaderInfoLog(fragmentShaderId, infoLogLength, null, errorMessage.ptr);

        std.debug.print("{s}\n", .{errorMessage});
    }

    const programId = c.glCreateProgram();
    c.glAttachShader(programId, vertexShaderId);
    c.glAttachShader(programId, fragmentShaderId);
    c.glLinkProgram(programId);
    c.glGetProgramiv(programId, c.GL_LINK_STATUS, &result);
    c.glGetProgramiv(programId, c.GL_INFO_LOG_LENGTH, &infoLogLength);
    if (infoLogLength > 0) {
        const errorMessage = std.heap.page_allocator.alloc(u8, infoLogLength + 1) catch return;
        defer std.heap.page_allocator.free(errorMessage);

        c.glGetShaderInfoLog(programId, infoLogLength, null, errorMessage.ptr);

        std.debug.print("{s}\n", .{errorMessage});
    }

    c.glDetachShader(programId, vertexShaderId);
    c.glDetachShader(programId, fragmentShaderId);

    c.glDeleteShader(vertexShaderId);
    c.glDeleteShader(fragmentShaderId);

    return programId;
}

pub fn main() u8 {
    var window: ?*c.GLFWwindow = null;
    const width = 900;
    const height = 600;

    if (glfw_aux.setupGLFW(&window, width, height) != 0) {
        std.log.err("Failed at: setupGLFW", .{});
        return 1;
    }
    defer c.glfwTerminate();

    c.glewExperimental = c.GL_TRUE;
    const errGlewInit = c.glewInit();
    if (errGlewInit != c.GLEW_OK) {
        std.log.err("Failed at: glewInit\n\t=> {s}", .{c.glewGetErrorString(errGlewInit)});
        return 1;
    }

    // var vertexArrayId: c.GLuint = 0;
    // c.glGenVertexArrays(1, &vertexArrayId);
    // c.glBindVertexArray(vertexArrayId);

    // const programId = loadShaders("../shader/shader.vert", "../shader/shader.frag");

    // var matrixId = c.glGetUniformLocation(programId, "MVP");

    c.glfwSetInputMode(window, c.GLFW_STICKY_KEYS, c.GLFW_TRUE);
    while (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) != c.GLFW_PRESS and c.glfwWindowShouldClose(window) == 0) {
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    return 0;
}
