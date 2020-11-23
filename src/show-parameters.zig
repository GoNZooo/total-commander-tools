const std = @import("std");

pub fn main() anyerror!void {
    const parameters = try std.process.argsAlloc(std.heap.page_allocator);
    std.debug.print("Arguments:\n", .{});
    for (parameters) |p, i| {
        std.debug.print("{}: {}\n", .{ i, p });
    }

    _ = try std.io.getStdIn().reader().readByte();
}
