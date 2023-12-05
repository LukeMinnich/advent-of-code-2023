const std = @import("std");
const print = std.debug.print;
const split = std.mem.split;
const splitAny = std.mem.splitAny;
const trim = std.mem.trim;

const card_count = 215;

const ScratcherSet = std.bit_set.IntegerBitSet(100);

fn process_card(card_txt: []const u8, card_no: usize, card_values: []u32) !void {
    var splits = splitAny(u8, card_txt, ":|");
    _ = splits.next().?; // Card number

    // zig fmt: off
    var winners   = ScratcherSet.initEmpty();
    var scratched = ScratcherSet.initEmpty();
    // zig fmt: on

    var winner_iter = split(u8, splits.next().?, " ");
    while (winner_iter.next()) |winning_no| {
        if (winning_no.len == 0) // Why is this necessary? Shouldn't iterator discard zero-length slices?
            continue;
        winners.set(try std.fmt.parseUnsigned(u8, trim(u8, winning_no, " "), 10));
    }

    var scratched_iter = split(u8, splits.next().?, " ");
    while (scratched_iter.next()) |scratched_no| {
        if (scratched_no.len == 0)
            continue;
        scratched.set(try std.fmt.parseUnsigned(u8, trim(u8, scratched_no, " "), 10));
    }

    scratched.setIntersection(winners);
    const num_winners: u32 = @intCast(scratched.count());
    const factor: u32 = card_values[card_no];

    var i: usize = 0;
    while (i < num_winners) : (i += 1) {
        const card_idx = card_no + i + 1;
        if (card_idx >= card_values.len)
            break;
        card_values[card_idx] += factor;
    }
}

fn solve_puzzle(input: []const u8) !usize {
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var card_values = [_]u32{0} ** card_count;

    var total: u32 = 0;
    var card_no: usize = 0;
    while (iter.next()) |line| : (card_no += 1) {
        card_values[card_no] += 1;
        total += card_values[card_no];
        try process_card(line, card_no, &card_values);
    }

    return total;
}

// zig fmt: off
const puzzle_input  = @embedFile("res/puzzle_input.txt");
const puzzle_sample = @embedFile("res/puzzle_sample2.txt");
// zig fmt: on

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var start = timer.read();
    const total = try solve_puzzle(puzzle_input);
    var end = timer.read();

    std.debug.print("\nSolution: {}\n", .{total});

    var elapsed_s = @as(f64, @floatFromInt(end - start)) / std.time.ns_per_s;
    std.debug.print("{d} ns, {d:.4} s\n", .{ end - start, elapsed_s });
}

test "part 2 test" {
    const total = solve_puzzle(puzzle_sample);
    try std.testing.expectEqual(total, 30);
}
