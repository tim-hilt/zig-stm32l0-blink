const cmsis = @cImport({
    @cInclude("stm32l0xx.h");
});

fn init_led() void {
    //   RCC->IOPENR |= RCC_IOPENR_GPIOBEN;
    //   GPIOB->MODER ^= GPIO_MODER_MODE3_1;
}

fn toggle_led() void {
    var i: usize = 0;
    while (i < 10000) {
        i += 1;
    }
    // toggle off
    // GPIOB->BSRR = GPIO_BSRR_BR_3;

    i = 0;
    while (i < 10000) {
        i += 1;
    }
    // toggle on
    // GPIOB->BSRR = GPIO_BSRR_BS_3;
}

pub fn main() void {
    init_led();

    while (true) {
        toggle_led();
    }
}
