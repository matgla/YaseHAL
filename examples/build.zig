const std = @import("std");

const examples = [_]Example{
    .{
        .name = "hello_world",
        .file = "hello_world/hello.zig",
    },
};

pub fn build(b: *std.Build) void {
    std.debug.print("Building examples\n", .{});
    for (examples) |example| {
        std.debug.print("Adding example: {s}\n", .{example.name});
        const exe = b.addExecutable(.{
            .name = example.name,
            .root_source_file = b.path(example.file),
            .target = b.host,
        });
        const artifact = b.addInstallArtifact(exe, .{});
        b.getInstallStep().dependOn(&artifact.step);
    }
}

const Example = struct {
    name: []const u8,
    file: []const u8,
};
