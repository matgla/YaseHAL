const hal = @import("hal");

pub fn Uart(comptime index: usize) type {
    const UartInstance = hal.Uart(index);
}
