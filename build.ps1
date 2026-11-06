# STM32F407 LED Blinker Build Script (PowerShell)
$ErrorActionPreference = "Stop"

Write-Host "==> Preparing build directory..." -ForegroundColor Cyan
if (-not (Test-Path -Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

Write-Host "==> Compiling firmware with arm-none-eabi-gcc..." -ForegroundColor Cyan
& arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -O0 -g3 -Wall -Wextra `
    -ffreestanding -fno-builtin -nostdlib -ffunction-sections -fdata-sections `
    -T linker.ld src/main.c `
    "-Wl,--gc-sections" "-Wl,-Map=build/blink.map" `
    -o build/blink.elf

if ($LASTEXITCODE -eq 0) {
    Write-Host "==> Build successful: build/blink.elf" -ForegroundColor Green
} else {
    Write-Host "==> Build failed." -ForegroundColor Red
    exit $LASTEXITCODE
}
