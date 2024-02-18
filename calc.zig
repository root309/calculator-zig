const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var argsList = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer argsList.deinit();

    // CLI
    var args = std.process.args();
    while (args.next()) |arg| {
        try argsList.append(arg);
    }

    if (argsList.items.len < 2) {
        try stdout.print("Usage: <expression>\n", .{});
        return;
    }

    // expr parse
    const expr = argsList.items[1];
    const result = try evalExpr(expr);
    try stdout.print("Result: {d}\n", .{result});
}

fn evalExpr(expr: []const u8) !i32 {
    var tokenizer = std.mem.tokenizeAny(u8, expr, " ");
    var sum: i32 = 0;
    var expectingNumber = true; // first token should be a number

    while (tokenizer.next()) |token| {
        if (expectingNumber) {
            // add number to sum
            const num = try std.fmt.parseInt(i32, token, 10);
            sum += num;
            expectingNumber = false; // next should be an operator
        } else {
            // check for operator
            if (!std.mem.eql(u8, token, "+")) return error.InvalidOperator;
            expectingNumber = true; // next should be a number
        }
    }

    // error handling
    if (expectingNumber) return error.InvalidExpression;

    return sum;
}
