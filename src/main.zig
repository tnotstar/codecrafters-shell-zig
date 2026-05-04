const std = @import("std");

const BuiltinCommands = enum {
    exit,
    echo,
    type,
};

pub fn main(init: std.process.Init) !void {
    var stdio_buffer: [4096]u8 = undefined;
    var stdin = std.Io.File.stdin().reader(init.io, &stdio_buffer);
    var stdout = std.Io.File.stdout().writer(init.io, &.{});

    while (true) {
        try stdout.interface.print("$ ", .{});

        const cmdLine = try stdin.interface.takeDelimiter('\n');
        var it = std.mem.tokenizeAny(u8, cmdLine.?, " ");

        const command = it.next() orelse continue;
        if (std.meta.stringToEnum(BuiltinCommands, command)) |builtin| {
            switch (builtin) {
                .exit => break,

                .echo => {
                    const rest = it.rest();
                    try stdout.interface.print("{s}\n", .{rest});
                    continue;
                },

                .type => {
                    const identifier = it.next() orelse {
                        try stdout.interface.print("type: missing identifier\n", .{});
                        continue;
                    };

                    if (std.meta.stringToEnum(BuiltinCommands, identifier)) |_| {
                        try stdout.interface.print("{s} is a shell builtin\n", .{identifier});
                    } else {
                        try stdout.interface.print("{s}: not found\n", .{identifier});
                    }
                },
            }
        } else {
            try stdout.interface.print("{s}: command not found\n", .{cmdLine.?});
        }
    }
}
