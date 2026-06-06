## Overview
This project demonstrates how a CPU stores and interprets data at the
lowest level. It contains two NASM assembly programs:

| Program | Description |
|---------|-------------|
| hello.asm | Hello World — .data section, strings, Linux syscalls |
| data_demo.asm | Bytes, words, dwords, ASCII, two's complement, little-endian |

---

## Environment
- OS: Ubuntu (WSL on Windows)
- Assembler: NASM
- Linker: LD
- Debugger: GDB
- Build tool: Make

---

## Setup Steps

### 1. Install WSL
Open PowerShell as Administrator and run:
```powershell
wsl --install
```
Restart your PC. Ubuntu installs by default.

### 2. Install Tools
Inside Ubuntu terminal:
```bash
sudo apt update
sudo apt install nasm gdb make git -y
```

### 3. Verify Installation
```bash
nasm --version
gdb --version
make --version
git --version
```

### 4. Clone Repository
```bash
git clone 
cd AssemblyProgramming/Task1
```

---

## Project Structure
Task1/
├── Makefile
├── README.md
├── asm/
│   ├── hello.asm
│   └── data_demo.asm
└── docs/
└── technical_note.md

---

## Build Instructions

### Build all programs
```bash
make
```

### Build individually
```bash
make hello
make data_demo
```

### Manual build (without Make)
```bash
# Step 1: Assemble (.asm → .o object file)
nasm -f elf64 asm/hello.asm -o hello.o

# Step 2: Link (.o → executable)
ld hello.o -o hello
```

---

## Running the Programs

```bash
# Run hello world
./hello

# Run data demo
./data_demo

# Build and run both
make run
```

---

## Expected Output

### hello
Hello, BIT 4220 Students!
Assembly sees everything as raw bytes.
Welcome to low-level programming!

### data_demo
=== ASCII Demonstration ===
ABCDE
Decimal codes: 65  66  67  68  69
Hex codes:     41  42  43  44  45
=== Data Sizes: byte / word / dword ===
byte_val  = 0x41       (1 byte  = 8 bits)
word_val  = 0x4142     (2 bytes = 16 bits, stored: 42 41)
dword_val = 0x41424344 (4 bytes = 32 bits, stored: 44 43 42 41)
=== Two's Complement ===
+5  =  00000101  (0x05)
-5  =  11111011  (0xFB) <- flip bits of +5, add 1
+5 + (-5) = 100000000 -> drop carry -> 0 (correct!)
=== Little-Endian Storage ===
Value 0x12345678 stored at address N:
N+0: 0x78  (least significant byte first)
N+1: 0x56
N+2: 0x34
N+3: 0x12  (most significant byte last)
All x86/x64 PCs are little-endian.
Demo complete.

---

## GDB Memory Inspection

```bash
gdb ./data_demo
(gdb) break _start
(gdb) run
(gdb) x/2xb &word_val     # shows: 0x42 0x41 (little-endian)
(gdb) x/4xb &dword_val    # shows: 0x44 0x43 0x42 0x41
(gdb) x/5xb &letters      # shows: 0x41 0x42 0x43 0x44 0x45
(gdb) quit
```

---

## Test Results
| Test | Command | Expected | Result |
|------|---------|----------|--------|
| Build succeeds | `make` | No errors | ✓ |
| hello runs | `./hello` | 3 lines printed | ✓ |
| data_demo runs | `./data_demo` | 4 sections printed | ✓ |
| Exit code | `echo $?` | 0 | ✓ |
| Clean works | `make clean` | Files removed | ✓ |

---

