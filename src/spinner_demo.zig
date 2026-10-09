const std = @import("std");
const cli = @import("cli.zig");

pub fn main(init: std.process.Init) !void {
    var spinner: cli.Spinner = .{
        .message = "Processing...",
    };

    for (0..20) |_| {
        spinner.tick();

        try std.Io.sleep(
            init.io,
            .fromMilliseconds(100),
            .awake,
        );
    }

    spinner.stop();
}
