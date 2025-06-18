const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <input>\n", .{args[0]});
        return error.InvalidArguments;
    }

    const dollars = try std.fmt.parseFloat(f64, args[1]);

    // Use curl to fetch the exchange rate JSON
    var curl_args = [_][]const u8{
        "curl", "-s", "https://api.exchangerate-api.com/v4/latest/USD"
    };
    var child = std.process.Child.init(&curl_args, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Inherit;
    try child.spawn();

    var stdout = child.stdout.?.reader();
    const response = try stdout.readAllAlloc(allocator, 16 * 1024);
    _ = try child.wait();
    defer allocator.free(response);

    var parsed = try std.json.parseFromSlice(std.json.Value, std.heap.page_allocator, response, .{});
    defer parsed.deinit();
    const root = parsed.value;

    const rates = root.object.get("rates") orelse {
        std.debug.print("Failed to parse exchange rates.\n", .{});
        return error.InvalidResponse;
    };

    const brl = rates.object.get("BRL") orelse {
        std.debug.print("Failed to find BRL exchange rate.\n", .{});
        return error.InvalidResponse;
    };

    const brlAmount = dollars * brl.float;
    var buf1: [32]u8 = undefined;
    var buf2: [32]u8 = undefined;
    const dollars_str = try std.fmt.bufPrint(&buf1, "{d:.2}", .{dollars});
    const brlAmount_str = try std.fmt.bufPrint(&buf2, "{d:.2}", .{brlAmount});
    std.debug.print("{s} USD is {s} BRL\n", .{dollars_str, brlAmount_str});
}