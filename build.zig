const std = @import("std");

fn findFile(allocator: std.mem.Allocator, path: []const u8, file: []const u8) anyerror![]const u8 {
    const dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    var walker = try dir.walk(allocator);
    defer walker.deinit();
    while (try walker.next()) |entry| {
        if (std.mem.eql(u8, entry.basename, file)) {
            return allocator.dupe(u8, entry.path);
        }
    }
    return error.FileNotFound;
}

fn importBoard(allocator: std.mem.Allocator, path: []const u8) void {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, 1024);
    defer allocator.free(data);
}

pub fn build(b: *std.Build) !void {
    const boardName = b.option([]const u8, "board", "Board name, corresponding JSON file must exist inside boards_path") orelse "";
    const boardsPath = b.option([]const u8, "board_path", "Path to board JSON definition files") orelse "boards";

    const boardFile = try std.fmt.allocPrint(b.allocator, "{s}.json", .{boardName});
    defer b.allocator.free(boardFile);

    std.debug.print("Board file: '{s}'\n", .{boardName});
    std.debug.print("Boards path: '{s}'\n", .{boardsPath});

    const path = findFile(b.allocator, boardsPath, boardFile) catch |err| {
        std.debug.print("Can't find board file: {s}, due to error: {any}\n", .{ boardName, err });
        unreachable;
    };
    defer b.allocator.free(path);
}
