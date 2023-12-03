var file = try std.fs.cwd().openFile("foo.txt", .{});
defer file.close();

var buf_reader = std.io.bufferedReader(file.reader());
var in_stream = buf_reader.reader();

var buf: [1024]u8 = undefined;
while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
    // do something with line...
}