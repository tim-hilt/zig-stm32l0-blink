const std = @import("std");

// TODO:
// - Put stm32model define here

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "blink",
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

    b.installArtifact(exe);
}
