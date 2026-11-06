# STM32F407 LED Blinker using Embedded C and Renode

![Platform](https://img.shields.io/badge/Platform-STM32F407VG-blue)
![Language](https://img.shields.io/badge/Language-Embedded%20C-orange)
![Architecture](https://img.shields.io/badge/Architecture-ARM%20Cortex--M4-green)
![Simulation](https://img.shields.io/badge/Simulation-Renode-purple)
![Compiler](https://img.shields.io/badge/Compiler-ARM%20GCC-red)

## Overview

This project is a register-level LED blinking application written in Embedded C for the STM32F407VG microcontroller and prepared for simulation with Renode.

It demonstrates how firmware can configure a GPIO peripheral through memory-mapped registers, compile with the ARM GNU Toolchain, and be loaded as an ELF image in a virtual STM32F4 Discovery platform.

> **Status:** The ELF build has been generated. Confirm the complete LED blinking behavior in Renode before describing the project as fully verified.

## Project Objectives

- Understand memory-mapped peripheral registers.
- Enable the GPIO peripheral clock through RCC.
- Configure PD12 as a GPIO output.
- Control an LED using GPIO output register operations.
- Cross-compile Embedded C for an ARM Cortex-M4.
- Generate an ELF firmware image and linker map.
- Load and inspect firmware in Renode.

## Target and Tools

| Item | Configuration |
|---|---|
| MCU target | STM32F407VG |
| CPU | ARM Cortex-M4 |
| Simulation platform | Renode STM32F4 Discovery |
| LED | Green onboard LED, PD12 |
| Language | Embedded C |
| Compiler | `arm-none-eabi-gcc` |
| Linker | GNU linker with `linker.ld` |

## Repository Structure

```text
STM32_LED_Blinker/
├── .gitignore               # Ignored build outputs and temp files
├── README.md                # Project documentation
├── linker.ld                # Linker script for STM32F407VG memory layout
├── Makefile                 # Cross-platform build automation
├── build.ps1                # PowerShell build script for Windows
├── stm32f4_discovery.resc   # Renode simulation script
├── src/
│   └── main.c               # Bare-metal register-level LED blinker source
└── build/                   # Build artifacts (generated, excluded from Git)
    ├── blink.elf
    └── blink.map
```

The `build/` directory contains generated files. The `.gitignore` excludes ELF, map, object, and dependency files from Git.

## GPIO Register Map

The firmware uses these STM32F4 register addresses:

| Register | Address | Purpose |
|---|---|---|
| `RCC_AHB1ENR` | `0x40023830` | Enables the GPIO Port D clock |
| `GPIOD_MODER` | `0x40020C00` | Selects the GPIO pin mode |
| `GPIOD_ODR` | `0x40020C14` | Sets or clears GPIO output pins |

### Enable the GPIOD Clock

```c
RCC_AHB1ENR |= (1U << 3);
```

### Configure PD12 as Output

Each GPIO pin uses two bits in `MODER`. The value `01` selects general-purpose output mode.

```c
GPIOD_MODER &= ~(3U << (12U * 2U));
GPIOD_MODER |=  (1U << (12U * 2U));
```

### Turn the LED On and Off

```c
/* LED ON */
GPIOD_ODR |= (1U << 12U);

/* LED OFF */
GPIOD_ODR &= ~(1U << 12U);
```

The firmware uses a software delay loop between output changes. Its duration depends on the CPU/emulator execution rate and compiler settings; it is not a calibrated one-second delay.

## Build Instructions

### Option 1: PowerShell Script (Windows)

Run the included automated build script:

```powershell
.\build.ps1
```

### Option 2: Direct Compiler Invocation

Ensure `arm-none-eabi-gcc` is in your `PATH`:

```powershell
arm-none-eabi-gcc --version
```

Create the build directory if it does not exist:

```powershell
New-Item -ItemType Directory -Force build
```

Compile the firmware:

```powershell
arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -O0 -g3 -Wall -Wextra -ffreestanding -fno-builtin -nostdlib -ffunction-sections -fdata-sections -T linker.ld src/main.c "-Wl,--gc-sections" "-Wl,-Map=build/blink.map" -o build/blink.elf
```

### Option 3: Using Make (Linux/macOS or MinGW)

```bash
make
```

### Generated Artifacts

```text
build/
├── blink.elf
└── blink.map
```

## Run in Renode

### Quick Launch using Script

Start Renode in the project directory and run:

```text
include @stm32f4_discovery.resc
start
```

### Or Manual Setup

In the Renode monitor:

```text
mach create
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery.repl
sysbus LoadELF @build/blink.elf
start
```

Inspect the LED model:

```text
gpioPortD.UserLED State
```

Inspect the GPIO registers:

```text
sysbus ReadDoubleWord 0x40023830
sysbus ReadDoubleWord 0x40020C00
sysbus ReadDoubleWord 0x40020C14
```

To stop continuous emulation:

```text
pause
```

`UserLED State` reports the LED state at the instant it is queried. A single reading does not prove that the LED is blinking. Verify changing GPIO output values or enable LED state logging while the emulation runs.

## Firmware Execution Sequence

The intended firmware loop is:

1. Enable the GPIOD peripheral clock.
2. Configure PD12 as an output.
3. Set PD12 high.
4. Wait using a software delay loop.
5. Set PD12 low.
6. Wait again and repeat indefinitely.

## Learning Outcomes

- Embedded C and bitwise operations.
- Volatile memory-mapped register access.
- RCC clock gating.
- STM32 GPIO configuration.
- ARM GCC cross-compilation.
- Linker scripts and ELF output.
- Virtual hardware emulation with Renode.

## Planned Improvements

- Replace the software delay with a hardware timer.
- Implement SysTick-based timing.
- Add interrupt-driven GPIO behavior.
- Add UART output for firmware diagnostics.
- Debug execution using GDB.
- Add a proper Cortex-M startup routine, including vector table, `.data` initialization, and `.bss` initialization.

## Author

**Grisler Paul J.**

Electronics and Communication Engineering  
Interests: Embedded Systems, Firmware Development, and Microcontrollers

- GitHub: [grislerpaul16-prog](https://github.com/grislerpaul16-prog)
- LinkedIn: [Grisler Paul](https://linkedin.com/in/grisler-paul-033aa1330)

---

This project is part of my hands-on learning journey in embedded systems and firmware engineering.
