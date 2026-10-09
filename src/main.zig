const std = @import("std");
const cli = @import("cli.zig");
const handlers = @import("commands.zig");

pub fn main(init: std.process.Init) !void {
    // 引数をスライスする
    // メモリが必要ならこのアロケータを使ってもらう
    const args = try init.minimal.args.toSlice(
        init.arena.allocator(),
    );

    const commands = [_]cli.Command{
        .{
            .name = "hello",
            .func = &handlers.hello,
            .req = &.{"greeting"},
        },
        .{
            .name = "help",
            .func = &handlers.help,
        },
        .{
            .name = "user:create",
            .func = &handlers.userCreate,
            .req = &.{"name"},
        },
    };

    const options = [_]cli.Option{
        .{
            .name = "name",
            .short = 'n',
            .long = "name",
        },
        .{
            .name = "greeting",
            .short = 'g',
            .long = "greeting",
        },
    };

    try cli.startWithArgs(&commands, &options, args, true);
}
