## Overview
This program processes student marks stored directly in memory.
It demonstrates six addressing modes while computing totals,
averages, highest, lowest and classification counts.

| Feature | Details |
|---------|---------|
| Language | NASM x86-64 Assembly |
| Platform | Linux / WSL Ubuntu |
| Array size | 10 marks (1 byte each) |
| Addressing modes | Immediate, Register, Direct, Indirect, Indexed, Based |

---

## Environment Setup

```bash
sudo apt update
sudo apt install nasm gdb make -y
```

Verify:
```bash
nasm --version
gdb --version
make --version
```

---

## Project Structure
Task3/
├── Makefile
├── README.md
├── asm/
│   └── marks_processor.asm
└── docs/
├── memory_map.md
└── test_cases.md

---

## Build Instructions

### Build the program
```bash
cd Task3
make
```

Expected output:
[NASM] Assembling marks_processor.asm...
[LD]   Linking marks_processor.o...
[DONE] marks_processor is ready

### Manual build
```bash
nasm -f elf64 asm/marks_processor.asm -o marks_processor.o
ld marks_processor.o -o marks_processor
```

### Clean compiled files
```bash
make clean
```

---

## Running the Program

```bash
./marks_processor
```

### Expected Output
=====================================
MARKS PROCESSOR — BIT 4220
=====================================
Marks in memory: 45 78 90 32 67 55 88 71 40 95Total:   661
Average: 66
Highest: 95
Lowest:  32--- Classifications ---
Distinctions (70-100): 5
Credits      (60-69):  1
Passes       (40-59):  3
Fails        (0-39):   1--- Addressing Modes Used ---
Immediate: marks_count = 10 (value in instruction)
Register:  mov rbx, rax (value from register)
Direct:    [marks] (fixed memory label)
Indirect:  [rbx] (address in register)
Indexed:   [marks + rcx*1] (base + index)
Based:     [rbx + 1] (base register + offset)
=====================================

---

## Addressing Modes Summary

| Mode | Example in Code | Where Used |
|------|----------------|-----------|
| Immediate | `mov rcx, 0` | Loop counters, syscall numbers |
| Register | `mov r14, rax` | Saving totals, passing values |
| Direct | `mov rbx, marks` | Getting array base address |
| Indirect | `byte [rbx]` | Loading first element via pointer |
| Indexed | `byte [marks + rcx]` | Looping through array elements |
| Based | `byte [rbx + rcx]` | Highest/lowest mark search |

---

## Classification Logic

```nasm
cmp rax, 70
jl .check_credit    ; mark < 70 → not distinction
inc r10             ; distinction count++

cmp rax, 60
jl .check_pass      ; mark < 60 → not credit
inc r11             ; credit count++

cmp rax, 40
jl .check_fail      ; mark < 40 → not pass
inc r12             ; pass count++

inc r13             ; fail count++
```

---

## GDB Memory Inspection

```bash
gdb ./marks_processor
(gdb) break _start
(gdb) run

# Inspect the marks array in memory
(gdb) x/10db &marks    # show 10 bytes as decimal

# Inspect registers during computation
(gdb) info registers rax rcx r14

# Watch classification counters
(gdb) info registers r10 r11 r12 r13

# Step one instruction at a time
(gdb) stepi
```

---

## Test Cases

| Test | Marks Array | D | C | P | F | Total | Avg |
|------|------------|---|---|---|---|-------|-----|
| Default | 45,78,90,32,67,55,88,71,40,95 | 5 | 1 | 3 | 1 | 661 | 66 |
| Boundaries | 0,39,40,69,70,100,50,65,75,85 | 4 | 2 | 2 | 2 | 653 | 65 |
| All fails | 0,5,10,15,20,25,30,35,38,39 | 0 | 0 | 0 | 10 | 217 | 21 |
| All dist | 70,72,75,78,80,85,88,90,95,100 | 10 | 0 | 0 | 0 | 833 | 83 |

---
