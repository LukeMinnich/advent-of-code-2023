const std = @import("std");
const print = std.debug.print;
const split = std.mem.split;
const splitAny = std.mem.splitAny;
const trim = std.mem.trim;

const ScratcherSet = std.bit_set.IntegerBitSet(100);

const ScratcherIterator = std.mem.TokenIterator(u8, .scalar);

const card_count = 215;

var cards_seen = std.bit_set.IntegerBitSet(card_count).initEmpty();
var card_values = [_]usize{0} ** card_count;

fn like_white_trash(iter: *ScratcherIterator, line: []const u8, line_no: usize) !usize {
    var splits = splitAny(u8, line, ":|");
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
    const num_winners = scratched.count();

    var copies: usize = 1;
    var i: usize = 0;
    while (iter.next()) |inner_line| {
        if (i >= num_winners)
            break;

        i += 1;
        const inner_line_no = line_no + i;

        if (cards_seen.isSet(inner_line_no)) {
            copies += card_values[inner_line_no];
        } else {
            var iter_copy = iter.*;
            const copied = try like_white_trash(&iter_copy, inner_line, inner_line_no);
            cards_seen.set(inner_line_no);
            card_values[inner_line_no] = copied;
            copies += copied;
        }
    }
    return copies;
}

fn solve_puzzle(input: []const u8) !usize {
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var copies: usize = 0;
    var line_no: usize = 0;
    while (iter.next()) |line| {
        line_no += 1;

        if (cards_seen.isSet(line_no)) {
            copies += card_values[line_no];
        } else {
            var iter_copy = iter;
            const copied = try like_white_trash(&iter_copy, line, line_no);
            cards_seen.set(line_no);
            card_values[line_no] = copied;
            copies += copied;
        }
    }
    return copies;
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
