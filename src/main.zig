const std = @import("std");
const assert = std.debug.assert;
const regs = @import("stm32l0x1.zig").devices.STM32L0x1.peripherals;

const Led = struct {
    const Self = @This();

    is_on: bool = false,

    pub fn init() Self {
        // TODO: Check, how methods of Mmio work and if there is one
        //  that is better suited
        regs.RCC.IOPENR.modify(.{
            .IOPBEN = 1,
        });
        regs.GPIOB.MODER.modify(.{
            .MODE3 = 1,
        });
        return .{};
    }

    pub fn on(self: *Self) void {
        regs.GPIOB.BSRR.modify(.{
            .BS3 = 1,
        });
        self.is_on = true;
    }

    pub fn off(self: *Self) void {
        regs.GPIOB.BSRR.modify(.{
            .BR3 = 1,
        });
        self.is_on = false;
    }

    pub fn toggle(self: *Self) void {
        if (self.is_on) {
            self.off();
        } else {
            self.on();
        }
    }
};

fn increase_clock_speed() void {
    regs.Flash.ACR.modify(.{
        .LATENCY = 1,
    });
    while (regs.Flash.ACR.read().LATENCY != 1) {}
    regs.RCC.CR.modify(.{
        .HSI16ON = 1,
    });
    while (regs.RCC.CR.read().HSI16RDYF != 1) {}
    regs.RCC.CFGR.modify(.{
        .PLLSRC = 0,
        .PLLMUL = 1,
        .PLLDIV = 1,
    });
    regs.RCC.CR.modify(.{
        .PLLON = 1,
    });
    while (regs.RCC.CR.read().PLLRDY != 1) {}
    regs.RCC.CFGR.modify(.{
        .SW = 3,
    });
    while (regs.RCC.CFGR.read().SWS != 3) {}
    return;
}

const Uart = struct {
    const Self = @This();

    var uart_buffer: [50]u8 = undefined;

    pub fn init() Self {
        regs.RCC.IOPENR.modify(.{
            .IOPAEN = 1,
        });
        regs.GPIOA.MODER.modify(.{
            .MODE2 = 2,
        });
        regs.GPIOA.AFRL.modify(.{
            .AFSEL2 = 4,
        });
        regs.RCC.AHBENR.modify(.{
            .DMAEN = 1,
        });
        regs.DMA1.CSELR.modify(.{
            .C4S = 4,
        });
        regs.DMA1.CPAR4.modify(.{
            .PA = regs.USART2.TDR.address(),
        });
        regs.DMA1.CMAR4.modify(.{
            .MA = @intFromPtr(&uart_buffer),
        });
        regs.DMA1.CCR4.modify(.{
            .MINC = 1,
            .DIR = 1,
        });
        regs.RCC.APB1ENR.modify(.{
            .USART2EN = 1,
        });
        regs.RCC.CCIPR.modify(.{
            .USART2SEL0 = 0,
            .USART2SEL1 = 0,
        });
        regs.USART2.BRR.modify(.{
            .DIV_Fraction = 0x5,
            .DIV_Mantissa = 0x11,
        });
        regs.USART2.CR3.modify(.{
            .DMAT = 1,
        });
        regs.USART2.CR1.modify(.{
            .UE = 1,
            .TE = 1,
        });

        return .{};
    }

    pub const Error = error{StringTooLarge};

    pub fn writeAll(self: Self, string: []const u8) Error!void {
        _ = self;

        const string_len: u16 = @intCast(string.len);
        if (string_len > uart_buffer.len) return Error.StringTooLarge;

        for (string, 0..) |char, i| {
            uart_buffer[i] = char;
        }
        regs.DMA1.CCR4.modify(.{
            .EN = 0,
        });
        regs.DMA1.CNDTR4.modify(.{
            .NDT = string_len,
        });
        regs.DMA1.CCR4.modify(.{
            .EN = 1,
        });
        while (regs.DMA1.ISR.read().TCIF4 != 1) {}
        regs.DMA1.IFCR.modify(.{
            .CTCIF4 = 1,
        });
    }

    pub fn writeBytesNTimes(self: Self, bytes: []const u8, n: usize) Error!void {
        if (n > uart_buffer.len) return Error.StringTooLarge;
        for (0..n) |_| {
            try self.writeAll(bytes);
        }
    }
};

fn toggle_led() !void {}

export fn _start() void {
    increase_clock_speed();

    const uart = Uart.init();
    var led = Led.init();

    var i: usize = 0;
    const ticks_delay = 100000;

    while (true) {
        // TODO: Use timer
        while (i < ticks_delay) {
            asm volatile ("nop");
            i += 1;
        }

        led.toggle();
        std.fmt.format(uart, "LED is {s}\n", .{if (led.is_on) "on" else "off"}) catch break;
        i = 0;
    }
}
