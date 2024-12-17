const std = @import("std");

const examples = [_]Example{
    .{
        .name = "hello_world",
        .file = "src/blinky.zig",
    },
};

pub fn build(b: *std.Build) void {
    std.debug.print("Building examples", .{});
    for (examples) |example| {
        const exe = b.addExecutable(.{
            .name = example.name,
            .root_source_file = b.path(example.file),
            .target = b.host,
        });
        b.installArtifact(exe);
    }
}

const Example = struct {
    name: []const u8,
    file: []const u8,
};
