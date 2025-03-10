const regs = @import("stm32l0x1.zig").devices.STM32L0x1.peripherals;

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
