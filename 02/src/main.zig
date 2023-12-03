const std = @import("std");

const Color = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
};

const RevealedSet = Color;

fn parse_chunk_as_revealed_set(chunk: []const u8) RevealedSet {
    var set = RevealedSet{};
    var color_pairs = std.mem.split(u8, chunk, ",");
    while (color_pairs.next()) |color_pair| {
        const color_pair_trimmed = std.mem.trim(u8, color_pair, " ");
        var splits = std.mem.split(u8, color_pair_trimmed, " ");
        const n_txt = splits.next().?;
        const n = std.fmt.parseUnsigned(u8, n_txt, 10) catch unreachable;
        const color_txt = splits.next().?;
        if (std.mem.eql(u8, color_txt, "red")) {
            set.r = n;
        } else if (std.mem.eql(u8, color_txt, "green")) {
            set.g = n;
        } else if (std.mem.eql(u8, color_txt, "blue")) {
            set.b = n;
        }
    }

    return set;
}

fn solve_puzzle(file: std.fs.File) !u32 {
    var istream = std.io.bufferedReader(file.reader());

    var buf: [256]u8 = undefined;
    var ostream = std.io.fixedBufferStream(&buf);

    // var sum_of_possible_game_ids: u32 = 0; // PART 1
    var sum_of_minimum_cube_powers: u32 = 0;

    var end_of_stream_found = false;
    while (!end_of_stream_found) {
        istream.reader().streamUntilDelimiter(ostream.writer(), '\n', ostream.buffer.len) catch |err| switch (err) {
            error.EndOfStream => end_of_stream_found = true,
            else => |e| return e,
        };

        const output = ostream.getWritten();
        const n_written = output.len;

        var splits = std.mem.splitAny(u8, ostream.buffer[0..n_written], ":;");
        var game_chunk = splits.next().?;
        _ = game_chunk;

        // PART 1
        // var game_splits = std.mem.split(u8, game_chunk, " ");
        // const game_txt = game_splits.next().?;
        // _ = game_txt;
        // const game_n_txt = game_splits.next() orelse break;
        // const game_n = std.fmt.parseUnsigned(u8, game_n_txt, 10) catch unreachable;

        // var max = RevealedSet{}; // PART 1
        var min = RevealedSet{};
        while (splits.next()) |chunk| {
            const set = parse_chunk_as_revealed_set(chunk);
            // PART 1
            // if (set.r > max.r)
            //     max.r = set.r;
            // if (set.g > max.g)
            //     max.g = set.g;
            // if (set.b > max.b)
            //     max.b = set.b;

            // PART 2
            if (set.r > min.r)
                min.r = set.r;
            if (set.g > min.g)
                min.g = set.g;
            if (set.b > min.b)
                min.b = set.b;
        }

        // PART 1
        // if (    max.r <= limit.r
        //     and max.g <= limit.g
        //     and max.b <= limit.b)
        //     sum_of_possible_game_ids += game_n;

        sum_of_minimum_cube_powers += @as(u32, min.r) * @as(u32, min.g) * @as(u32, min.b);

        ostream.reset();
    }

    // return sum_of_possible_game_ids; // PART 1
    return sum_of_minimum_cube_powers;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("res/puzzle_input.txt", .{});
    defer file.close();

    // const sum = try solve_puzzle(file, Color{ .r = 12, .g = 13, .b = 14 }); // PART 1
    const sum = try solve_puzzle(file);
    std.debug.print("\nSolution: {}\n", .{sum});
}

// test "part 1 test" {
//     var file = try std.fs.cwd().openFile("res/puzzle_sample1.txt", .{});
//     defer file.close();

//     const sum = try solve_puzzle(file, Color{ .r = 12, .g = 13, .b = 14 });
//     try std.testing.expectEqual(sum, 8);
// }

test "part 2 test" {
    var file = try std.fs.cwd().openFile("res/puzzle_sample2.txt", .{});
    defer file.close();

    const sum = try solve_puzzle(file);
    try std.testing.expectEqual(sum, 2286);
}
