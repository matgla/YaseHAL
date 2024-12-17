const std = @import("std");
const hal = @import("hal");

pub fn Uart(comptime index: usize) type {
    return struct {
        const Self = @This();

        pub const Writer = std.io.Writer(Self, WriteError, write_bytes);
    };
}
