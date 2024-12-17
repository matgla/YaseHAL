const std = @import("std");

const examples = @import("examples");

const BoardConfiguration = struct {
    soc: []const u8,
};

fn findFile(allocator: std.mem.Allocator, path: []const u8, file: []const u8) anyerror![]const u8 {
    const dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    var walker = try dir.walk(allocator);
    defer walker.deinit();
    while (try walker.next()) |entry| {
        if (std.mem.eql(u8, entry.basename, file)) {
            return try std.fmt.allocPrint(allocator, "{s}/{s}", .{ path, entry.path });
        }
    }
    return error.FileNotFound;
}

fn importBoardConfiguration(allocator: std.mem.Allocator, path: []const u8) !std.json.Parsed(BoardConfiguration) {
    std.debug.print("Using board configuration path: {s}\n", .{path});
    const data = try std.fs.cwd().readFileAlloc(allocator, path, 1024);
    defer allocator.free(data);
    return std.json.parseFromSlice(BoardConfiguration, allocator, data, .{
        .allocate = .alloc_always,
    });
}

fn initializeBoard(allocator: std.mem.Allocator, boardsPath: []const u8, boardName: []const u8) !void {
    const boardFile = try std.fmt.allocPrint(allocator, "{s}.json", .{boardName});
    defer allocator.free(boardFile);

    const boardConfigurationPath = findFile(allocator, boardsPath, boardFile) catch |err| {
        std.debug.print("Can't find the board file: {s}, due to an error: {any}\n", .{ boardName, err });
        unreachable;
    };
    const board = try importBoardConfiguration(allocator, boardConfigurationPath);
    defer board.deinit();
    std.debug.print("Board SOC: {s}\n", .{board.value.soc});

    const socFile = try std.fmt.allocPrint(allocator, "{s}.json", .{board.value.soc});
    defer allocator.free(socFile);

    const socConfigurationPath = findFile(allocator, "socs", socFile) catch |err| {
        std.debug.print("Can't find the soc file: {s}, due to an error: {any}\n", .{ socFile, err });
        unreachable;
    };
    std.debug.print("Using SOC configuration file: {s}\n", .{socConfigurationPath});
}

pub fn build(b: *std.Build) !void {
    const boardName = b.option([]const u8, "board", "Board name, corresponding JSON file must exist inside boards_path") orelse "";
    const boardsPath = b.option([]const u8, "board_path", "Path to board JSON definition files") orelse "boards";

    std.debug.print("Board file: '{s}'\n", .{boardName});
    std.debug.print("Boards path: '{s}'\n", .{boardsPath});

    try initializeBoard(b.allocator, boardsPath, boardName);

    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("hello.zig"),
        .target = b.host,
    });
    b.installArtifact(exe);
    _ = b.dependency("examples", .{});
}
