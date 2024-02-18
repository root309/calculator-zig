const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var stdin = std.io.getStdIn().reader();

    // Input
    try stdout.print("> ", .{});
    const expr = try stdin.readUntilDelimiterAlloc(std.heap.page_allocator, '\n', 4096);

    // Analyze and calculate the equation
    const result = try evalExpr(expr);
    try stdout.print("Result: {d}\n", .{result});

    // deallocation
    std.heap.page_allocator.free(expr);
}

fn evalExpr(expr: []const u8) !i32 {
    var tokenizer = std.mem.tokenizeAny(u8, expr, " ");
    var sum: i32 = 0;
    var expectingNumber = true; // first token is a number

    while (tokenizer.next()) |token| {
        if (expectingNumber) {
            // Add the values to the total
            const num = try std.fmt.parseInt(i32, token, 10);
            sum += num;
            expectingNumber = false; // Next should be the operator
        } else {
            // check operator
            if (!std.mem.eql(u8, token, "+")) return error.InvalidOperator;
            expectingNumber = true; // Next should be the numbers
        }
    }

    // error handling
    if (expectingNumber) return error.InvalidExpression;

    return sum;
}
