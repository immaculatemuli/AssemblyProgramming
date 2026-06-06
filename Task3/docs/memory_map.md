File 3 of 5 — Task3/docs/memory_map.md
Run this:
bashnano Task3/docs/memory_map.md
Paste this in:
markdown# Memory Map — BIT 4220 Task 3: Marks Processor
## Variables, Arrays and Addressing Modes

---

## 1. Memory Layout Overview

When the program loads into memory Linux divides it into segments.
Each section in our NASM code maps to a segment in memory:
High addresses
┌─────────────────────────────┐
│         STACK               │ ← grows downward
│   (local variables, ret)    │   rbp, rsp point here
├─────────────────────────────┤
│                             │
│         BSS SEGMENT         │ ← uninitialised data
│   result_buf (16 bytes)     │   zeroed by OS at load
│                             │
├─────────────────────────────┤
│                             │
│         DATA SEGMENT        │ ← initialised data
│   marks array (10 bytes)    │   values set at compile time
│   all string labels         │
│                             │
├─────────────────────────────┤
│                             │
│         TEXT SEGMENT        │ ← executable instructions
│   _start, print_number,     │   read-only at runtime
│   all loop code             │
│                             │
└─────────────────────────────┘
Low addresses

---

## 2. Data Section Variables and Offsets

### marks array (starting at label `marks`)
Offset  Label         Size    Value   Meaning
──────  ─────         ────    ─────   ───────
+0      marks[0]      1 byte  45      Student 1 mark
+1      marks[1]      1 byte  78      Student 2 mark
+2      marks[2]      1 byte  90      Student 3 mark
+3      marks[3]      1 byte  32      Student 4 mark
+4      marks[4]      1 byte  67      Student 5 mark
+5      marks[5]      1 byte  55      Student 6 mark
+6      marks[6]      1 byte  88      Student 7 mark
+7      marks[7]      1 byte  71      Student 8 mark
+8      marks[8]      1 byte  40      Student 9 mark
+9      marks[9]      1 byte  95      Student 10 mark

Total array size: 10 bytes
Element size: 1 byte (db — define byte)

### BSS Section
Label        Size     Purpose
─────        ────     ───────
result_buf   16 bytes Temporary buffer for printing numbers

---

## 3. Addressing Modes Used in the Program

### Mode 1 — Immediate Addressing
The value is embedded directly inside the instruction.
No memory access is needed.

```nasm
mov rcx, 0              ; load the value 0 directly into rcx
mov rax, 0              ; load the value 0 directly into rax
cmp rcx, marks_count    ; compare rcx with immediate value 10
mov rdi, 1              ; load file descriptor 1 directly
```

Used in: initialising counters, loop limits, syscall numbers
Where in code: _start, all loop initialisations

---

### Mode 2 — Register Addressing
The value is already in a register. Move between registers.

```nasm
mov rbx, rax            ; copy value from rax into rbx
mov r14, rax            ; save total from rax into r14
mov r8,  rax            ; save highest mark into r8
add rax, rbx            ; add register rbx to register rax
```

Used in: saving computed values, passing values between operations
Where in code: total computation, highest/lowest tracking

---

### Mode 3 — Direct Addressing
Access a fixed memory location using a label name.
The assembler replaces the label with the actual address.

```nasm
mov rbx, marks          ; load the ADDRESS of marks into rbx
movzx rax, byte [marks] ; load the VALUE at address marks
```

Used in: getting the base address of the marks array
Where in code: highest_loop and lowest_loop initialisations

---

### Mode 4 — Indirect Addressing
A register holds the memory address. Access the value
at that address using square brackets.

```nasm
mov rbx, marks          ; rbx = address of marks array
movzx rax, byte [rbx]   ; load value AT the address in rbx
```

Think of it like a pointer in C:
```c
int *ptr = marks;
int val  = *ptr;    // same as [rbx] in assembly
```

Used in: loading the first mark to initialise highest/lowest
Where in code: highest_loop and lowest_loop first element load

---

### Mode 5 — Indexed Addressing
Combine a base label with an index register to access
array elements. This is the assembly equivalent of marks[i].

```nasm
movzx rax, byte [marks + rcx]   ; load marks[rcx]
```

Equivalent in C:
```c
rax = marks[rcx];
```

As rcx goes 0, 1, 2 ... 9, this accesses each mark in order.

Used in: printing all marks, total computation, classification
Where in code: print_marks_loop, total_loop, classify_loop

---

### Mode 6 — Based Addressing
A base register holds the array address. An offset
(register or constant) is added to access elements.

```nasm
mov rbx, marks              ; rbx = base address of array
movzx rax, byte [rbx + rcx] ; load marks[rcx] via base + index
movzx rax, byte [rbx + 1]   ; load second element via base + constant
```

Difference from indexed: the base is a register not a label.
This is useful when you need to pass array addresses to
subroutines, since you cannot pass labels as parameters.

Used in: highest_loop and lowest_loop element access
Where in code: .highest_loop, .lowest_loop body

---

## 4. Register Usage Map
Register  Purpose in this program
────────  ────────────────────────
rax       General computation, syscall number, current mark
rbx       Base pointer to marks array, temp storage
rcx       Loop counter / array index (0 to 9)
rdx       Remainder in division, syscall byte count
rdi       Syscall file descriptor
rsi       Syscall buffer pointer
r8        Highest mark storage
r9        Lowest mark storage
r10       Distinction count
r11       Credit count
r12       Pass count
r13       Fail count
r14       Total sum storage
r15       Average storage

---

## 5. How Indexing Relates to High-Level Array Access

In a high-level language like Python or C:

```python
marks = [45, 78, 90, 32, 67, 55, 88, 71, 40, 95]
total = 0
for i in range(10):
    total += marks[i]
```

In assembly this becomes:

```nasm
marks   db 45, 78, 90, 32, 67, 55, 88, 71, 40, 95
        mov rax, 0      ; total = 0
        mov rcx, 0      ; i = 0
loop:
        movzx rbx, byte [marks + rcx]  ; rbx = marks[i]
        add rax, rbx                   ; total += marks[i]
        inc rcx                        ; i++
        cmp rcx, 10                    ; if i < 10
        jl loop                        ;   go back to loop
```

The only difference is that assembly makes the memory address
arithmetic visible — you see exactly how marks[i] is computed
as a base address plus an offset.

---
