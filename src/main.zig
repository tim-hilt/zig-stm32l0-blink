const std = @import("std");

const regs = @import("stm32l0x1.zig").devices.STM32L0x1.peripherals;
const Led = @import("led.zig");
const Uart = @import("uart.zig");
const Timer = @import("timer.zig");

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

export fn _start() void {
    increase_clock_speed();

    const uart = Uart.init();
    var led = Led.init();
    const timer = Timer.init();

    while (true) {
        timer.sleep_ms(1000);
        led.toggle();
        std.fmt.format(uart, "Timer at {d}\n", .{timer.read()}) catch break;
    }
}
