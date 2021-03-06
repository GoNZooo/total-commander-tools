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

pub const SourcesAndTarget = struct {
    sources: []Source,
    target: Target,
};

pub const SourceAndTarget = struct {
    source: Source,
    target: Target,
};

pub fn getSource(parameters: []const []const u8) !Source {
    return if (parameters.len != 1) error.NotExactlyOneSource else Source{ .value = parameters[0] };
}

pub fn getSources(allocator: *mem.Allocator, parameters: []const []const u8) ![]Source {
    if (parameters.len < 1) {
        return error.NoSources;
    } else {
        var sources = try allocator.alloc(Source, parameters.len);
        for (sources) |*source, i| {
            source.* = Source{ .value = try allocator.dupe(u8, parameters[i]) };
        }

        return sources;
    }
}

pub fn getSourcesAndTarget(
    allocator: *mem.Allocator,
    parameters: []const []const u8,
) !SourcesAndTarget {
    if (parameters.len < 2) {
        return error.NotEnoughEntriesForSourceAndTarget;
    } else {
        var sources = try allocator.alloc(Source, parameters.len - 1);
        for (sources) |*source, i| {
            source.* = Source{ .value = try allocator.dupe(u8, parameters[i]) };
        }
        var target = try allocator.create(Target);

        return SourcesAndTarget{
            .sources = sources,
            .target = Target{ .value = try allocator.dupe(u8, parameters[parameters.len - 1]) },
        };
    }
}

pub fn getSourceAndTarget(
    allocator: *mem.Allocator,
    parameters: []const []const u8,
) !SourceAndTarget {
    switch (parameters.len) {
        2 => {
            var sources = try allocator.create(Source);
            var target = try allocator.create(Target);

            return SourceAndTarget{
                .source = Source{ .value = try allocator.dupe(u8, parameters[0]) },
                .target = Target{ .value = try allocator.dupe(u8, parameters[1]) },
            };
        },
        0, 1 => return error.NotEnoughParameters,
        else => return error.TooManySources,
    }
}

test "`getSource`" {
    testing.expectEqual(
        Source{ .value = "source" },
        try getSource(&single_source_parameters),
    );

    testing.expectEqual(getSource(&multiple_source_parameters), error.NotExactlyOneSource);
}

test "`getSources`" {
    const sources_result = try getSources(heap.page_allocator, &multiple_source_parameters);
    testing.expectEqualSlices(
        u8,
        multiple_source_parameters[0],
        sources_result[0].value,
    );
    testing.expectEqualSlices(
        u8,
        multiple_source_parameters[1],
        sources_result[1].value,
    );
}

test "`getSourcesAndTarget`" {
    const sources_and_target_result = try getSourcesAndTarget(
        heap.page_allocator,
        &multiple_source_and_target_parameters,
    );
    testing.expectEqualSlices(
        u8,
        "source1",
        sources_and_target_result.sources[0].value,
    );
    testing.expectEqualSlices(
        u8,
        "source2",
        sources_and_target_result.sources[1].value,
    );
    testing.expectEqualSlices(
        u8,
        "target",
        sources_and_target_result.target.value,
    );
}

test "`getSourceAndTarget`" {
    const source_and_target_result = try getSourceAndTarget(
        heap.page_allocator,
        &source_and_target_parameters,
    );
    testing.expectEqualSlices(
        u8,
        "source",
        source_and_target_result.source.value,
    );
    testing.expectEqualSlices(
        u8,
        "target",
        source_and_target_result.target.value,
    );

    // errors
    testing.expectEqual(
        getSourceAndTarget(heap.page_allocator, &single_source_parameters),
        error.NotEnoughParameters,
    );

    testing.expectEqual(
        getSourceAndTarget(
            heap.page_allocator,
            &multiple_source_and_target_parameters,
        ),
        error.TooManySources,
    );
}

const source_and_target_parameters = [_][]const u8{ "source", "target" };

const multiple_source_and_target_parameters = [_][]const u8{ "source1", "source2", "target" };

const single_source_parameters = [_][]const u8{"source"};

const multiple_source_parameters = [_][]const u8{ "source1", "source2" };
