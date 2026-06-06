# Flag Analysis Table — BIT 4220 Task 2: ALU Simulator
## CPU Flags After Selected Operations

---

## What Are CPU Flags?

After every arithmetic or logical operation the CPU automatically
updates a special register called RFLAGS. Individual bits inside
this register are called flags. Four flags are critical:

| Flag | Full Name      | Set to 1 when...                          |
|------|---------------|-------------------------------------------|
| CF   | Carry Flag    | Unsigned result overflows (carry/borrow)  |
| ZF   | Zero Flag     | Result equals zero                        |
| SF   | Sign Flag     | Result is negative (bit 7 = 1)            |
| OF   | Overflow Flag | Signed result overflows its range         |

---

## How to Inspect Flags in GDB

```bash
gdb ./alu_simulator
(gdb) break _start
(gdb) run
(gdb) info registers eflags
```

After stepping through an operation:
```bash
(gdb) stepi          # execute one instruction
(gdb) info registers # see all registers including flags
```

---

## Flag Analysis Table

| # | Operation      | Inputs      | Result | CF | ZF | SF | OF | Notes |
|---|---------------|-------------|--------|----|----|----|----|-------|
| 1 | ADD           | 5 + 3       | 8      | 0  | 0  | 0  | 0  | Normal addition, no flags set |
| 2 | ADD (zero)    | 5 + 0       | 5      | 0  | 0  | 0  | 0  | ZF=0 because result is not zero |
| 3 | SUB (zero)    | 5 - 5       | 0      | 0  | 1  | 0  | 0  | ZF=1 because result equals zero |
| 4 | SUB (negative)| 3 - 7       | -4     | 1  | 0  | 1  | 0  | SF=1 (negative), CF=1 (borrow) |
| 5 | MUL           | 9 x 9       | 81     | 0  | 0  | 0  | 0  | Result fits in rax, no overflow |
| 6 | AND (mask)    | 6 AND 3     | 2      | 0  | 0  | 0  | 0  | 0110 AND 0011 = 0010 |
| 7 | AND (zero)    | 5 AND 0     | 0      | 0  | 1  | 0  | 0  | ZF=1, result is zero |
| 8 | XOR (same)    | 7 XOR 7     | 0      | 0  | 1  | 0  | 0  | ZF=1, same values XOR = 0 |
| 9 | OR            | 5 OR 2      | 7      | 0  | 0  | 0  | 0  | 0101 OR 0010 = 0111 |
|10 | NOT           | NOT 5       | 250    | 0  | 0  | 1  | 0  | SF=1, all bits flipped |

---

## Detailed Explanation of Selected Operations

### Operation 3 — SUB producing Zero (ZF=1)
5 - 5 = 0
00000101

00000101
──────────
00000000   ← result is zero → ZF = 1

**Why it matters:** Zero Flag is used in loops. `JZ` (jump if zero)
and `JNZ` (jump if not zero) check ZF to decide whether to continue
looping. This is how assembly implements `while` and `for` loops.

---

### Operation 4 — SUB producing Negative (SF=1, CF=1)
3 - 7 = -4
00000011

00000111
──────────
11111100   ← bit 7 is 1 → SF = 1 (negative result)
← borrow occurred → CF = 1

**Why it matters:** Sign Flag tells the CPU whether the result
should be treated as negative. Signed comparison instructions
like `JL` (jump if less) use SF and OF together.

---

### Operation 8 — XOR with itself (ZF=1)
7 XOR 7 = 0
00000111
00000111
────────
00000000   ← ZF = 1
**Why it matters:** XOR-ing a register with itself is the fastest
way to zero a register in assembly. `XOR rax, rax` is used
everywhere in optimised code instead of `MOV rax, 0`.

---

### Operation 10 — NOT (SF=1)
NOT 00000101 = 11111010 (0xFA = 250 unsigned / -6 signed)
Bit 7 = 1 → SF = 1
**Why it matters:** NOT is used in cryptography, checksums,
and device register manipulation to invert bit patterns.

---

## Why Overflow Matters in Real Systems

### The Problem
Every register has a fixed size. An 8-bit register holds values
0 to 255 (unsigned) or -128 to +127 (signed). If a calculation
produces a result outside this range the value silently wraps
around — this is called overflow.

### Real-World Consequences

| System | Overflow effect |
|--------|----------------|
| Prepaid meter | Balance wraps from 0 to 255 — free units appear |
| Bank system | Account balance wraps from negative to positive |
| Exploit development | Integer overflow used to bypass security checks |
| Embedded device | Sensor reading wraps causing wrong decisions |

### Famous Example
In 1996 the Ariane 5 rocket self-destructed 37 seconds after launch
because a 64-bit floating point value was converted into a 16-bit
integer and overflowed. The flight computer interpreted the garbage
value as flight data and corrected for a trajectory error that did
not exist — causing the rocket to break apart.

### How Assembly Handles It
```nasm
add rax, rbx        ; perform addition
jo  overflow_handler ; jump if overflow flag (OF) is set
jc  carry_handler   ; jump if carry flag (CF) is set
```

Always check flags after arithmetic in safety-critical systems.

