const std = @import("std");
const print = std.debug.print;
const split = std.mem.split;
const splitAny = std.mem.splitAny;
const trim = std.mem.trim;

const ScratcherSet = std.bit_set.IntegerBitSet(100);

fn solve_puzzle(input: []const u8) !usize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var total: usize = 0;
    while (lines.next()) |line| {
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
        const scratched_count = scratched.count();
        if (scratched_count > 0)
            total += std.math.pow(usize, 2, (scratched.count() - 1));
    }
    return total;
}

// zig fmt: off
const puzzle_input  = @embedFile("res/puzzle_input.txt");
const puzzle_sample = @embedFile("res/puzzle_sample1.txt");
// zig fmt: on

pub fn main() !void {
    const total = try solve_puzzle(puzzle_input);
    std.debug.print("\nSolution: {}\n", .{total});
}

test "part 1 test" {
    const total = solve_puzzle(puzzle_sample);
    try std.testing.expectEqual(total, 13);
}
