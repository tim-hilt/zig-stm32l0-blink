const regs = @import("stm32l0x1.zig").devices.STM32L0x1.peripherals;

const Self = @This();

pub fn init() Self {
    regs.RCC.APB1ENR.modify(.{
        .TIM2EN = 1,
    });
    regs.TIM2.PSC.modify(.{
        .PSC = 32000 - 1,
    });
    regs.TIM2.CR1.modify(.{
        .CEN = 1,
    });
    return .{};
}

pub fn sleep_ms(self: Self, comptime ms: u16) void {
    const start = self.read();
    while (self.read() -% start < ms) {}
}

pub inline fn read(self: Self) u16 {
    _ = self;
    return regs.TIM2.CNT.read().CNT_L;
}

// TODO: Figure out a good way to time duration of a function
