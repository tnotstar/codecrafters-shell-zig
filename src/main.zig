const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var stdio_buffer: [4096]u8 = undefined;
    var stdin = std.Io.File.stdin().reader(init.io, &stdio_buffer);
    var stdout = std.Io.File.stdout().writer(init.io, &.{});

    while (true) {
        try stdout.interface.print("$ ", .{});

        const commandLine = try stdin.interface.takeDelimiter('\n');
        if (std.mem.eql(u8, commandLine.?, "exit")) {
            break;
        }

        if (std.mem.startsWith(u8, commandLine.?, "echo ")) {
            try stdout.interface.print("{s}\n", .{commandLine.?[5..]});
            continue;
        }

        try stdout.interface.print("{s}: command not found\n", .{commandLine.?});
    }
}
