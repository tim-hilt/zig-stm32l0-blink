const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "blink.elf",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .thumb,
            .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus },
            .os_tag = .freestanding,
            .abi = .eabi,
        }),
        .optimize = .ReleaseSmall,
    });
    exe.setLinkerScript(b.path("STM32L011K4Tx_FLASH.ld"));
    exe.addAssemblyFile(b.path("src/startup_stm32l011xx.s"));
    exe.addIncludePath(b.path("inc"));
    exe.root_module.addCMacro("STM32L011xx", "");

    b.installArtifact(exe);

    const tool_run = b.addSystemCommand(&.{"/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin/STM32_Programmer_CLI"});
    tool_run.addArgs(&.{
        "-c",
        "port=SWD",
        "-w",
        b.fmt("{s}/bin/{s}", .{ b.install_prefix, exe.name }),
        "-s",
        "0x08000000",
    });

    const flash_step = b.step("flash", "Flash the mcu");
    flash_step.dependOn(&tool_run.step);
}
