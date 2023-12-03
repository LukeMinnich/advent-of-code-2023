const std = @import("std");

const DigitLookup = struct {
    name: []const u8,
    value: u8,
};

const digit_lookups = [_]DigitLookup{
    // zig fmt: off
    .{ .name = "one"  , .value = 1 },
    .{ .name = "two"  , .value = 2 },
    .{ .name = "three", .value = 3 },
    .{ .name = "four" , .value = 4 },
    .{ .name = "five" , .value = 5 },
    .{ .name = "six"  , .value = 6 },
    .{ .name = "seven", .value = 7 },
    .{ .name = "eight", .value = 8 },
    .{ .name = "nine" , .value = 9 },
    // zig fmt: on
};

fn calibration_value(file: std.fs.File) !u32 {
    var istream = std.io.bufferedReader(file.reader());

    var buf: [64]u8 = undefined;
    var ostream = std.io.fixedBufferStream(&buf);

    var total: u32 = 0;
    var end_of_stream_found = false;

    while (!end_of_stream_found) {
        istream.reader().streamUntilDelimiter(ostream.writer(), '\n', ostream.buffer.len) catch |err| switch (err) {
            error.EndOfStream => end_of_stream_found = true,
            else => |e| return e,
        };

        const output = ostream.getWritten();
        const n_written = output.len;

        var a: ?u8 = null;
        var b: ?u8 = null;
        for (buf[0..n_written], 0..n_written) |char, i| {
            var value: ?u8 = null;
            if (std.ascii.isDigit(char)) {
                value = char - '0';
            } else if (std.ascii.isAlphabetic(char)) {
                for (digit_lookups) |lookup| {
                    const name = lookup.name;
                     // buffer is garbage past end of written contents
                    if (i + name.len > n_written)
                        continue;
                    if (std.mem.eql(u8, buf[i..i + name.len], name))
                        value = lookup.value;
                }
            }

            if (value != null) {
                if (a == null) {
                    a = value;
                }
                b = value;
            }
        }

        if (a != null and b != null) {
            total += a.? * 10 + b.?;
        }

        ostream.reset();
    }

    return total;
}

pub fn main() !void {
    var puzzle_file = try std.fs.cwd().openFile("res/puzzle_input.txt", .{});
    defer puzzle_file.close();

    const total = try calibration_value(puzzle_file);
    std.debug.print("Total: {}\n", .{total});
}

test "part 1 test" {
    var file = try std.fs.cwd().openFile("res/puzzle_sample1.txt", .{});
    defer file.close();

    const total = try calibration_value(file);
    try std.testing.expectEqual(total, 142);
}

test "part 2 test" {
    var file = try std.fs.cwd().openFile("res/puzzle_sample2.txt", .{});
    defer file.close();

    const total = try calibration_value(file);
    try std.testing.expectEqual(total, 281);
}
