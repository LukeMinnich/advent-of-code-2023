const std = @import("std");
const print = std.debug.print;
const IdList = std.ArrayList(u32);
const IdRangeList = std.ArrayList(IdRange);
const MapRuleList = std.ArrayList(MapRule);

const IdRange = struct {
    start: u64,
    count: u32,
};

const MapRule = struct {
    src_idx: u64,
    dst_idx: u64,
    count: u32,
};

const MapIterator = std.mem.TokenIterator(u8, .scalar);

fn parse_seeds_part1(line: []const u8, seeds: *IdList) !void {
    var splits = std.mem.splitAny(u8, line, ": ");
    _ = splits.next().?; // `seeds`

    while (splits.next()) |split| {
        if (split.len < 1)
            continue;
        const seed_txt = std.mem.trim(u8, split, " ");
        const seed_num = try std.fmt.parseUnsigned(u32, seed_txt, 10);
        try seeds.append(seed_num);
    }
}

fn parse_seeds_part2(line: []const u8, seeds: *IdRangeList) !void {
    var splits = std.mem.splitAny(u8, line, ": ");
    _ = splits.next().?; // `seeds`

    while (splits.next()) |split_left| {
        if (split_left.len < 1)
            continue;

        // const split_right: []u8 = splits.next().?;

        // zig fmt: off
        const start_txt = std.mem.trim(u8, split_left,  " ");
        const count_txt = std.mem.trim(u8, splits.next().?, " ");
        // zig fmt: on

        const start = try std.fmt.parseUnsigned(u64, start_txt, 10);
        const count = try std.fmt.parseUnsigned(u32, count_txt, 10);
        const range = IdRange{
            .start = start,
            .count = count,
        };
        // print("range: {}\n", .{range});
        try seeds.append(range);
    }
}

fn parse_map_rule(line: []const u8) !MapRule {
    var splits = std.mem.splitScalar(u8, line, ' ');
    return MapRule{
        // zig fmt: off
        .dst_idx = try std.fmt.parseUnsigned(u32, splits.next().?, 10),
        .src_idx = try std.fmt.parseUnsigned(u32, splits.next().?, 10),
        .count   = try std.fmt.parseUnsigned(u32, splits.next().?, 10),
        // zig fmt: on
    };
}

fn parse_map_rule_block(iter: *MapIterator, rules: *MapRuleList) !void {
    while (iter.next()) |line| {
        if (line[line.len - 1] == ':')
            break;
        const rule = try parse_map_rule(line);
        // print("RULE ({}, {}, {})\n", .{ rule.dst_idx, rule.src_idx, rule.count });
        rules.append(rule) catch unreachable;
    }
}

fn parse_map_rules(iter: *MapIterator, map_rules: *std.ArrayList(MapRuleList)) !void {
    while (iter.peek() != null) {
        // print("\nPARSING MAP \n", .{});
        var rules = MapRuleList.init(map_rules.allocator);
        parse_map_rule_block(iter, &rules) catch unreachable;
        try map_rules.append(rules);
    }
}

fn map_seeds_by_rule_list_part1(ids: IdList, rules: MapRuleList) void {
    id_loop: for (ids.items) |*id| {
        for (rules.items) |rule| {
            if (id.* >= rule.src_idx and id.* < rule.src_idx + rule.count) {
                const src: i64 = @intCast(rule.src_idx);
                const dst: i64 = @intCast(rule.dst_idx);
                const sid: i64 = @intCast(id.*);
                id.* = @intCast(sid + (dst - src));
                continue :id_loop;
            }
        }
    }
}

fn map_seeds_by_rule_list_part2(ids: IdList, rules: MapRuleList) void {
    id_loop: for (ids.items) |*id| {
        for (rules.items) |rule| {
            if (id.* >= rule.src_idx and id.* < rule.src_idx + rule.count) {
                const src: i64 = @intCast(rule.src_idx);
                const dst: i64 = @intCast(rule.dst_idx);
                const sid: i64 = @intCast(id.*);
                id.* = @intCast(sid + (dst - src));
                continue :id_loop;
            }
        }
    }
}

fn solve_puzzle(input: []const u8) !usize {
    var iter = std.mem.tokenizeScalar(u8, input, '\n');

    const seed_txt = iter.next().?;
    // var ids = IdList.init(arena.allocator());
    // parse_seeds_part1(seed_txt, &ids) catch unreachable;

    var id_ranges = IdRangeList.init(arena.allocator());
    parse_seeds_part2(seed_txt, &id_ranges) catch unreachable;

    _ = iter.next().?; // blank line

    var all_map_rules = std.ArrayList(MapRuleList).init(arena.allocator());
    try parse_map_rules(&iter, &all_map_rules);

    // for (all_map_rules.items) |rule_list|
    //     map_seeds_by_rule_list_part1(ids, rule_list);

    for (all_map_rules.items) |rule_list|
        map_seeds_by_rule_list_part2(id_ranges, rule_list);

    var lowest: u32 = std.math.maxInt(u32);
    // for (ids.items) |id| {
    //     if (id < lowest)
    //         lowest = id;
    // }

    return lowest;
}

// zig fmt: off
const puzzle_input  = @embedFile("res/puzzle_input.txt");
const puzzle_sample = @embedFile("res/puzzle_sample1.txt");
// zig fmt: on

var arena: std.heap.ArenaAllocator = undefined;

pub fn main() !void {
    arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var timer = try std.time.Timer.start();
    var start = timer.read();
    const total = try solve_puzzle(puzzle_input);
    var end = timer.read();

    std.debug.print("\nSolution: {}\n", .{total});

    var elapsed_s = @as(f64, @floatFromInt(end - start)) / std.time.ns_per_s;
    std.debug.print("{d} ns, {d:.4} s\n", .{ end - start, elapsed_s });
}

test "part 1 test" {
    arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const total = solve_puzzle(puzzle_sample);
    try std.testing.expectEqual(total, 35);
}
