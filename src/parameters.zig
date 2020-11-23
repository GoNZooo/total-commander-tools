const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const heap = std.heap;

pub const Source = struct {
    value: []const u8,
};

pub const Target = struct {
    value: []const u8,
};

pub fn getSource(parameters: []const []const u8) !Source {
    return if (parameters.len != 2) error.TooManySources else Source{ .value = parameters[1] };
}

pub fn getSources(allocator: *mem.Allocator, parameters: []const []const u8) ![]Source {
    if (parameters.len < 2) {
        return error.NoSources;
    } else {
        var sources = try allocator.alloc(Source, parameters.len - 1);
        for (sources) |*source, i| {
            source.* = Source{ .value = try allocator.dupe(u8, parameters[i + 1]) };
        }

        return sources;
    }
}

pub fn getSourceAndTarget(parameters: [][]const u8) !Source {
    return if (parameters.len < 2) error.NoSources else parameters[1..];
}

test "getting sources and targets works" {
    const single_source_parameters = [_][]const u8{ "programName", "source" };
    testing.expectEqual(
        Source{ .value = "source" },
        try getSource(&single_source_parameters),
    );

    const multiple_source_parameters = [_][]const u8{ "programName", "source1", "source2" };
    const sources_result = try getSources(heap.page_allocator, &multiple_source_parameters);
    testing.expectEqualSlices(
        u8,
        "source1",
        sources_result[0].value,
    );
    testing.expectEqualSlices(
        u8,
        "source2",
        sources_result[1].value,
    );
}
