const std = @import("std");

pub const MAX_COMMANDS: u8 = 10;
pub const MAX_OPTIONS: u8 = 20;

const Byte = u8;
const Slice = []const Byte;
const Slices = []const Slice;

pub const Command = struct {
    name: Slice,
    func: FnType,
    req: Slices = &.{},
    opt: Slices = &.{},

    const FnType = *const fn ([]const Option) anyerror!void;
};

pub const Option = struct {
    name: Slice,
    func: ?FnType = null,
    short: Byte,
    long: Slice,
    value: Slice = "",

    const FnType = *const fn (Slice) anyerror!void;
};

pub const Error = error{
    NoArgsProvided, // コマンドを指定していない
    UnknownCommand, // 未登録のコマンドを指定した
    UnknownOption, // 未登録のオプションを指定した
    MissingRequiredOption, // 必須オプションが足りない
    UnexpectedArgument, // 想定してない引数がある
    TooManyCommands, // 登録したコマンド数が上限を超えた
    TooManyOptions, // オプション数が上限を超えた
};

pub fn startWithArgs(
    commands: []const Command,
    options: []const Option,
    args: anytype,
    debug: bool,
) !void {
    if (commands.len > MAX_COMMANDS) {
        return Error.TooManyCommands;
    }

    if (options.len > MAX_OPTIONS) {
        return Error.TooManyOptions;
    }

    if (args.len < 2) {
        return Error.NoArgsProvided;
    }

    const command_name = args[1];
    var detected_command: ?Command = null;

    for (commands) |cmd| {
        // スライスの中身の比較にはstd.mem.eql()を使う
        if (std.mem.eql(u8, cmd.name, command_name)) {
            detected_command = cmd;
            break;
        }
    }

    const cmd = detected_command orelse return Error.UnknownCommand;

    if (debug) {
        std.debug.print("Detected command: {s}\n", .{cmd.name});
    }

    var detected_options: [MAX_OPTIONS]Option = undefined;
    var detected_len: usize = 0;
    var i: usize = 2;

    while (i < args.len) {
        const arg = args[i];

        if (!std.mem.startsWith(u8, arg, "-")) {
            return Error.UnexpectedArgument;
        }

        const is_long = std.mem.startsWith(u8, arg, "--");
        const option_name = if (is_long) arg[2..] else arg[1..];

        var matched_option: ?Option = null;

        for (options) |opt| {
            const matches = if (is_long)
                std.mem.eql(u8, option_name, opt.long)
            else
                option_name.len == 1 and option_name[0] == opt.short;

            if (matches) {
                matched_option = opt;
                break;
            }
        }

        var opt = matched_option orelse return Error.UnknownOption;

        if (i + 1 < args.len and !std.mem.startsWith(u8, args[i + 1], "-")) {
            opt.value = args[i + 1];
            i += 1;
        } else {
            opt.value = "";
        }

        if (detected_len >= MAX_OPTIONS) {
            return Error.TooManyOptions;
        }

        detected_options[detected_len] = opt;
        detected_len += 1;
        i += 1;
    }

    const used_options = detected_options[0..detected_len];

    if (debug) {
        for (used_options) |opt| {
            std.debug.print(
                "Detected options: {s} = {s}\n",
                .{ opt.name, opt.value },
            );
        }
    }

    for (cmd.req) |required_name| {
        var found = false;

        for (used_options) |opt| {
            if (std.mem.eql(u8, required_name, opt.name)) {
                found = true;
                break;
            }
        }

        if (!found) {
            return Error.MissingRequiredOption;
        }
    }

    // if (!cmd.func(used_options)) {
    //     return Error.CommandExecutionFailed;
    // }
    //
    // for (used_options) |opt| {
    //     if (opt.func) |func| {
    //         if (!func(opt.value)) {
    //             return Error.CommandExecutionFailed;
    //         }
    //     }
    // }
    try cmd.func(used_options);

    for (used_options) |opt| {
        if (opt.func) |func| {
            try func(opt.value);
        }
    }
}

pub const Color = enum {
    reset,
    red,
    green,
    cyan,

    pub fn ansiCode(self: Color) []const u8 {
        return switch (self) {
            .reset => "\x1b[0m",
            .red => "\x1b[31m",
            .green => "\x1b[32m",
            .cyan => "\x1b[36m",
        };
    }
};

pub fn printColored(
    color: Color,
    comptime fmt: []const u8,
    args: anytype,
) void {
    std.debug.print(
        "{s}" ++ fmt ++ "{s}",
        .{color.ansiCode()} ++ args ++ .{Color.reset.ansiCode()},
    );
}

pub const Spinner = struct {
    message: []const u8,
    current: usize = 0,
    frames: []const []const u8 = &.{ "|", "/", "-", "\\" },

    pub fn tick(self: *Spinner) void {
        std.debug.print(
            "\r\x1b[2K{s} {s}",
            .{ self.frames[self.current], self.message },
        );

        self.current = (self.current + 1) % self.frames.len;
    }

    pub fn stop(self: *const Spinner) void {
        std.debug.print(
            "\r\x1b[2KDone: {s}\n",
            .{self.message},
        );
    }
};
