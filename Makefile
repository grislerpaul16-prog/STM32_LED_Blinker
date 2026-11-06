# Toolchain
CC      = arm-none-eabi-gcc
SIZE    = arm-none-eabi-size

# Target and paths
TARGET    = build/blink.elf
MAP       = build/blink.map
SRC       = src/main.c
LDSCRIPT  = linker.ld
BUILD_DIR = build

# Flags
MCU     = -mcpu=cortex-m4 -mthumb
CFLAGS  = $(MCU) -O0 -g3 -Wall -Wextra -ffreestanding -fno-builtin -nostdlib -ffunction-sections -fdata-sections
LDFLAGS = -T $(LDSCRIPT) -Wl,--gc-sections -Wl,-Map=$(MAP)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC) $(LDSCRIPT)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) $(SRC) -o $@
	@$(SIZE) $@

clean:
	rm -rf $(BUILD_DIR)

