```markdown
# FasmOS-tut

A minimal operating system written in FASM (flat assembler). Boots from a raw binary image and displays "FasmOS" on screen.

## Prerequisites

- [FASM](https://flatassembler.net/) — flat assembler
- [QEMU](https://www.qemu.org/) — for testing in a virtual machine

### Install on Ubuntu/Debian

```bash
sudo apt install fasm qemu-system-x86
```

### Install on Arch Linux

```
sudo pacman -S fasm qemu-full
```

### Install on Windows

Download FASM from [flatassembler.net](https://flatassembler.net/download.php) and QEMU from [qemu.org](https://www.qemu.org/download/#windows).

## Build

```bash
fasm fasmos.asm fasmos.bin
```

## Run

```bash
qemu-system-x86_64 -drive format=raw,file=fasmos.bin
```

## Write to USB (optional)

> **Warning:** This will overwrite the first sector of the drive. Make sure you select the correct device.

```bash
sudo dd if=fasmos.bin of=/dev/sdX bs=512 count=1
```

## Project Structure

```
FasmOS-tut/
└── fasmos.asm    — bootloader source code
```

## How It Works

- BIOS loads the first 512-byte sector from disk to memory at address `0x7C00`
- The bootloader sets up segment registers and stack
- Clears the screen using BIOS interrupt `int 10h`
- Prints "FasmOS" character by character via BIOS teletype output
- Halts the CPU in an infinite loop
- The last two bytes `0xAA55` mark the sector as bootable

## Screenshot

<img width="1920" height="1051" alt="image" src="https://github.com/user-attachments/assets/f81005be-be90-4464-8d7e-86f5971d4441" />


## License

This project is released into the public domain. Use it however you like.
```
