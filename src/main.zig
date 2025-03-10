const std = @import("std");

const regs = @import("stm32l0x1.zig").devices.STM32L0x1.peripherals;
const Led = @import("led.zig");
const Uart = @import("uart.zig");

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
