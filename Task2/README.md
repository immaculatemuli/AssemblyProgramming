# BIT 4220 — Assembly Programming
## Task 2: ALU Simulator — Prepaid Meter Module
**Group Work Session 1 | Due: 10 June 2026**

---

## Group Members
| Name | Student ID | Role |
|------|-----------|------|
| [Name 1] | [ID] | alu_simulator.asm |
| [Name 2] | [ID] | Flag analysis table |
| [Name 3] | [ID] | Makefile & build |
| [Name 4] | [ID] | GDB screenshots |
| [Name 5] | [ID] | README & testing |

---

## Overview
This program simulates a prepaid utility meter computation module.
It is a menu-driven ALU simulator written in NASM assembly that
demonstrates arithmetic and logical operations at the CPU level.

| Feature | Details |
|---------|---------|
| Language | NASM x86-64 Assembly |
| Platform | Linux / WSL Ubuntu |
| Input | Keyboard (Linux syscall sys_read) |
| Operations | ADD, SUB, MUL, DIV, AND, OR, XOR, NOT |

---

## Environment Setup

### Tools Required
```bash
sudo apt update
sudo apt install nasm gdb make -y
```

### Verify Installation
```bash
nasm --version
gdb --version
make --version
```

---

## Project Structure
File 4 of 4 — Task2/README.md
Run this:
bashnano Task2/README.md
Paste this in:
markdown# BIT 4220 — Assembly Programming
## Task 2: ALU Simulator — Prepaid Meter Module
**Group Work Session 1 | Due: 10 June 2026**

---

## Group Members
| Name | Student ID | Role |
|------|-----------|------|
| [Name 1] | [ID] | alu_simulator.asm |
| [Name 2] | [ID] | Flag analysis table |
| [Name 3] | [ID] | Makefile & build |
| [Name 4] | [ID] | GDB screenshots |
| [Name 5] | [ID] | README & testing |

---

## Overview
This program simulates a prepaid utility meter computation module.
It is a menu-driven ALU simulator written in NASM assembly that
demonstrates arithmetic and logical operations at the CPU level.

| Feature | Details |
|---------|---------|
| Language | NASM x86-64 Assembly |
| Platform | Linux / WSL Ubuntu |
| Input | Keyboard (Linux syscall sys_read) |
| Operations | ADD, SUB, MUL, DIV, AND, OR, XOR, NOT |

---

## Environment Setup

### Tools Required
```bash
sudo apt update
sudo apt install nasm gdb make -y
```

### Verify Installation
```bash
nasm --version
gdb --version
make --version
```

---

## Project Structure
Task2/
├── Makefile
├── README.md
├── asm/
│   └── alu_simulator.asm
└── docs/
└── flag_analysis.md

---

## Build Instructions

### Build the program
```bash
cd Task2
make
```

Expected output:
[NASM] Assembling alu_simulator.asm...
[LD]   Linking alu_simulator.o...
[DONE] alu_simulator is ready

### Manual build (without Make)
```bash
nasm -f elf64 asm/alu_simulator.asm -o alu_simulator.o
ld alu_simulator.o -o alu_simulator
```

### Clean compiled files
```bash
make clean
```

---

## Running the Program

```bash
./alu_simulator
```

### Sample Session
================================
ALU SIMULATOR — BIT 4220
Prepaid Meter Module

ADD  (add units)
SUB  (subtract usage)
MUL  (multiply rate)
DIV  (divide balance)
AND  (bit mask status)
OR   (set status bits)
XOR  (toggle status bits)
NOT  (invert bits)
EXIT
================================
Enter first number (0-9): 5
Enter second number (0-9): 3
Choose option (1-9): 1
Operation: ADD
Result: 8


---

## Operations Explained

| Operation | Instruction | Example | Result | Use in Meter |
|-----------|------------|---------|--------|-------------|
| ADD | `add rax, rbx` | 5 + 3 | 8 | Add purchased units |
| SUB | `sub rax, rbx` | 5 - 3 | 2 | Subtract consumed units |
| MUL | `mul rbx` | 5 x 3 | 15 | Multiply units by rate |
| DIV | `div rbx` | 6 / 3 | 2 | Divide balance |
| AND | `and rax, rbx` | 6 AND 3 | 2 | Mask device status bits |
| OR  | `or rax, rbx`  | 5 OR 2 | 7 | Set status bits |
| XOR | `xor rax, rbx` | 7 XOR 7 | 0 | Toggle status bits |
| NOT | `not rax`      | NOT 5 | 250 | Invert all bits |

---

## ASCII Input Conversion

When a user types '5' on the keyboard, the CPU receives the
ASCII code 53 (not the number 5). We convert it like this:

```nasm
movzx rax, byte [num1_buf]  ; load ASCII character
sub   rax, '0'              ; subtract 48 to get actual digit
```

This is because '0' = 48, '1' = 49 ... '9' = 57 in ASCII.
Subtracting '0' (48) gives the actual numeric value.

---

## Flag Inspection with GDB

```bash
gdb ./alu_simulator
(gdb) break _start
(gdb) run
(gdb) stepi
(gdb) info registers eflags
```

### Reading the EFLAGS register
eflags = 0x246
Binary: 0000 0010 0100 0110
│ │ │ └── CF (Carry)
│ │ └──── PF (Parity)
│ └────── ZF (Zero)
└──────── SF (Sign)

---

## Test Cases

| Test | Input 1 | Input 2 | Operation | Expected | Flags |
|------|---------|---------|-----------|----------|-------|
| Normal ADD | 5 | 3 | ADD | 8 | None |
| Zero result | 5 | 5 | SUB | 0 | ZF=1 |
| Negative result | 3 | 7 | SUB | -4 | SF=1, CF=1 |
| Multiply | 4 | 3 | MUL | 12 | None |
| AND mask | 6 | 3 | AND | 2 | None |
| XOR self | 7 | 7 | XOR | 0 | ZF=1 |
| Divide by zero | 5 | 0 | DIV | Error msg | None |
| Invalid choice | 5 | 3 | 0 | Error msg | None |

---
