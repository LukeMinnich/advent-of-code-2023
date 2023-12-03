const std = @import("std");

fn solve_puzzle(file: std.fs.File) !void {
    var istream = std.io.bufferedReader(file.reader());

    var buf: [1024]u8 = undefined;
    var ostream = std.io.fixedBufferStream(&buf);

    var end_of_stream_found = false;
    while (!end_of_stream_found) {
        istream.reader().streamUntilDelimiter(ostream.writer(), '\n', ostream.buffer.len) catch |err| switch (err) {
            error.EndOfStream => end_of_stream_found = true,
            else => |e| return e,
        };

        const output = ostream.getWritten();
        const n_written = output.len;
        _ = n_written;
    }
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("res/puzzle_input.txt", .{});
    defer file.close();

    try solve_puzzle(file);
    std.debug.print("\nSolution: \n", .{});
}

test "part 1 test" {
    var file = try std.fs.cwd().openFile("res/puzzle_sample1.txt", .{});
    defer file.close();

    try solve_puzzle(file);
}

test "part 2 test" {
    var file = try std.fs.cwd().openFile("res/puzzle_sample2.txt", .{});
    defer file.close();

    try solve_puzzle(file);
}
