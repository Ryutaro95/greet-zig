const std = @import("std");
const cli = @import("cli.zig");

pub fn hello(options: []const cli.Option) bool {
    var name: []const u8 = "World";
    var greeting: []const u8 = "";

    for (options) |opt| {
        if (std.mem.eql(u8, opt.name, "name")) {
            if (opt.value.len > 0) {
                name = opt.value;
            }
        } else if (std.mem.eql(u8, opt.name, "greeting")) {
            greeting = opt.value;
        }
    }

    if (greeting.len == 0) {
        std.debug.print("Greeting must not be empty.\n", .{});
        return false;
    }

    cli.printColored(
        .green,
        "{s}, {s}!\n",
        .{ greeting, name },
    );
    return true;
}

pub fn help(_: []const cli.Option) bool {
    std.debug.print(
        \\Usage: hello_zig <command> [options]
        \\
        \\Commands:
        \\  hello         Greeting someone
        \\  help          Show this help message
        \\  user:create   Create a user (requires --name)
        \\Options for hello:
        \\  -g, --greeting <value>   Greeting to use (required)
        \\  -n, --name <value>       Name to greet
        \\
    , .{});

    return true;
}

pub fn userCreate(options: []const cli.Option) bool {
    for (options) |opt| {
        if (std.mem.eql(u8, opt.name, "name")) {
            if (opt.value.len == 0) {
                std.debug.print("Name mut not be empty.\n", .{});
                return false;
            }

            std.debug.print(
                "Creating user: {s}\n",
                .{opt.value},
            );
            return true;
        }
    }
    return false;
}
