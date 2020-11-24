const std = @import("std");
const debug = std.debug;
const heap = std.heap;

const parameters = @import("./parameters.zig");

pub fn main() anyerror!void {
    const arguments = try std.process.argsAlloc(std.heap.page_allocator);
    const sourcesAndTarget = try parameters.getSourcesAndTarget(heap.page_allocator, arguments[1..]);

    debug.print("Sources:\n", .{});
    for (sourcesAndTarget.sources) |source, i| {
        debug.print("\t{}: {}\n", .{ i, source.value });
    }
    debug.print("Target: {}\n", .{sourcesAndTarget.target.value});

    _ = try std.io.getStdIn().reader().readByte();
}
