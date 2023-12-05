const std = @import("std");

var prev = [_]u8{'.'} ** 143;
var curr = [_]u8{'.'} ** 143;
var next = [_]u8{'.'} ** 143;

fn accumulate_gear_ratio(line: []const u8, seek_pos: usize, adjacent_parts: *u32, gear_ratio: *u32) bool {
    if (!std.ascii.isDigit(line[seek_pos]))
        return false;

    // seek backward for starting digit
    var start: usize = seek_pos; // range inclusive
    while (start > 0) : (start -= 1) {
        if (!std.ascii.isDigit(line[start - 1]))
            break;
    }

    // seek forward for ending digit
    var end: usize = seek_pos + 1; // range exclusive
    while (end < line.len) : (end += 1) {
        if (!std.ascii.isDigit(line[end]))
            break;
    }

    const num = std.fmt.parseInt(u32, line[start..end], 10) catch unreachable;
    gear_ratio.* *= num;
    adjacent_parts.* += 1;
    return true;
}

fn solve_puzzle(file: std.fs.File) !u32 {
    var istream = std.io.bufferedReader(file.reader());
    var ostream = std.io.fixedBufferStream(&next);

    var total: u32 = 0;
    var end_of_stream_found = false;
    while (!end_of_stream_found) {
        istream.reader().streamUntilDelimiter(ostream.writer(), '\n', ostream.buffer.len) catch |err| switch (err) {
            error.EndOfStream => end_of_stream_found = true,
            else => |e| return e,
        };

        var i: u8 = 0;
        while (i < curr.len) : (i += 1) {
            if ('*' != curr[i])
                continue;

            var adjacent_parts: u32 = 0;
            var gear_ratio: u32 = 1;

            // Check specific pattern around the `gear ratio` character.
            // .....123.....
            // .....4*5.....
            // .....678.....
            //
            // Give priority to locations above and below the character, because that position
            // has a tendency to merge into surrounding L/R positions.
            //
            // There's no need to bounds check against start / end of line or first / last lines
            // because we've post-processed the puzzle input to always have an extra buffer
            // character or line.

            // zig fmt: off
            // row above
            if (   !accumulate_gear_ratio(&prev, i    , &adjacent_parts, &gear_ratio)) { // 2
                _ = accumulate_gear_ratio(&prev, i - 1, &adjacent_parts, &gear_ratio);   // 1
                _ = accumulate_gear_ratio(&prev, i + 1, &adjacent_parts, &gear_ratio);   // 3
            }

            // same row
            {
                _ = accumulate_gear_ratio(&curr, i - 1, &adjacent_parts, &gear_ratio);   // 4
                _ = accumulate_gear_ratio(&curr, i + 1, &adjacent_parts, &gear_ratio);   // 5
            }

            // row above
            if (   !accumulate_gear_ratio(&next, i    , &adjacent_parts, &gear_ratio)) { // 7
                _ = accumulate_gear_ratio(&next, i - 1, &adjacent_parts, &gear_ratio);   // 6
                _ = accumulate_gear_ratio(&next, i + 1, &adjacent_parts, &gear_ratio);   // 8
            }
            // zig fmt: on

            if (adjacent_parts == 2)
                total += gear_ratio;
        }

        // PART 1
        // while (i < curr.len) : (i += 1) {
        //     if (!std.ascii.isDigit(curr[i]))
        //         continue;

        //     var j: u8 = i + 1; // non-inclusive range end
        //     while (j < curr.len) : (j += 1) {
        //         // std.debug.print("i = {}, j = {}\n", .{ i, j });
        //         if (!std.ascii.isDigit(curr[j]))
        //             break;
        //     }

        //     std.debug.print("i = {u}, j = {u}\n", .{ i, j });
        //     std.debug.print("slice: {s}\n", .{curr[i..j]});

        //     var found = false;
        //     if (!found) {
        //         for (prev[i - 1 .. j + 1]) |char| {
        //             if ('.' == char or std.ascii.isAlphanumeric(char))
        //                 continue;
        //             found = true;
        //             break;
        //         }
        //     }
        //     if (!found) {
        //         for (curr[i - 1 .. j + 1]) |char| {
        //             if ('.' == char or std.ascii.isAlphanumeric(char))
        //                 continue;
        //             found = true;
        //             break;
        //         }
        //     }
        //     if (!found) {
        //         for (next[i - 1 .. j + 1]) |char| {
        //             if ('.' == char or std.ascii.isAlphanumeric(char))
        //                 continue;
        //             found = true;
        //             break;
        //         }
        //     }

        //     if (found)
        //         total += num;

        //     i = j;
        // }

        std.mem.copy(u8, &prev, &curr);
        std.mem.copy(u8, &curr, &next);

        ostream.reset();
    }
    return total;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("res/puzzle_input.txt", .{});
    defer file.close();

    const total: u32 = try solve_puzzle(file);
    std.debug.print("\nSolution: {}\n", .{total});
}

// test "part 1 test" {
//     var file = try std.fs.cwd().openFile("res/puzzle_sample1.txt", .{});
//     defer file.close();

//     const total: u32 = try solve_puzzle(file);
//     try std.testing.expectEqual(total, 4361);
// }

test "part 2 test" {
    var file = try std.fs.cwd().openFile("res/puzzle_sample2.txt", .{});
    defer file.close();

    const total: u32 = try solve_puzzle(file);
    try std.testing.expectEqual(total, 467835);
}
