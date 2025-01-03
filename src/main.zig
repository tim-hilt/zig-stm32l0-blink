const cmsis = @cImport({
    @cDefine("STM32L011xx", {});
    @cInclude("stm32l0xx.h");
});

fn init_led() void {
    const RCC_IOPENR: *u32 = @ptrFromInt(cmsis.RCC.*.IOPENR);
    const GPIOB_MODER: *u32 = @ptrFromInt(cmsis.GPIOB.*.MODER);
    RCC_IOPENR.* |= cmsis.RCC_IOPENR_GPIOBEN;
    GPIOB_MODER.* ^= cmsis.GPIO_MODER_MODE3_1;
}

fn toggle_led() void {
    const GPIOB_BSRR: *u32 = @ptrFromInt(cmsis.GPIOB.*.BSRR);

    var i: usize = 0;
    while (i < 10000) {
        i += 1;
    }
    // toggle off
    GPIOB_BSRR.* = cmsis.GPIO_BSRR_BR_3;

    i = 0;
    while (i < 10000) {
        i += 1;
    }
    // toggle on
    GPIOB_BSRR.* = cmsis.GPIO_BSRR_BS_3;
}

export fn main() void {
    init_led();

    while (true) {
        toggle_led();
    }
}
