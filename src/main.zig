const regs = @import("STM32L0x1.zig").devices.STM32L0x1.peripherals;

fn init_led() void {
    // const RCC_IOPENR: *volatile u32 = @ptrFromInt(0x4002102C);
    // const GPIOB_MODER: *volatile u32 = @ptrFromInt(0x50000400);
    // RCC_IOPENR.* |= cmsis.RCC_IOPENR_GPIOBEN;
    // GPIOB_MODER.* ^= cmsis.GPIO_MODER_MODE3_1;
    // stm32.types.peripherals.RCC.IOPENR.modify(.{
    //     .GPIOBEN = 1,
    // });
    regs.RCC.IOPENR.IOPBEN = 1;
}

fn toggle_led() void {
    // const GPIOB_BSRR: *volatile u32 = @ptrFromInt(0x50000418);

    // var i: usize = 0;
    // const ticks_delay = 100000;
    // while (i < ticks_delay) {
    //     asm volatile ("nop");
    //     i += 1;
    // }
    // // toggle off
    // GPIOB_BSRR.* = cmsis.GPIO_BSRR_BR_3;

    // i = 0;
    // while (i < ticks_delay) {
    //     asm volatile ("nop");
    //     i += 1;
    // }
    // // toggle on
    // GPIOB_BSRR.* = cmsis.GPIO_BSRR_BS_3;
}

export fn _start() void {
    init_led();

    while (true) {
        toggle_led();
    }
}
