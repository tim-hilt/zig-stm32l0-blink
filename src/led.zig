const regs = @import("stm32l0x1.zig").devices.STM32L0x1.peripherals;

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
