
## 1. Introduction

When a CPU processes information it does not understand words or numbers
the way humans do. Everything inside a computer is stored and manipulated
as a sequence of binary digits called bits. Understanding how data is
represented at this level is the foundation of assembly programming,
reverse engineering, digital forensics, and embedded systems development.

This note explains five key concepts: binary, hexadecimal, ASCII,
two's complement, and little-endian storage.

---

## 2. Binary Representation

A bit is the smallest unit of data — it holds either 0 or 1.
Eight bits form a byte, which is the standard unit in assembly programming.

In binary (base-2), each digit position represents a power of 2:
Position:  7    6    5    4    3    2    1    0
Value:    128   64   32   16    8    4    2    1
Example — the number 65:
65 = 64 + 1 = 01000001 in binary

In NASM you can write binary literals directly:
```nasm
mov al, 01000001b   ; load 65 into register AL
```

Binary matters because CPU logic gates operate on individual bits.
Reading device status registers, decoding network packets, and
analysing firmware all require binary fluency.

---

## 3. Hexadecimal Representation

Binary numbers become long and hard to read. Hexadecimal (base-16)
is a compact alternative where each hex digit represents exactly 4 bits:

| Decimal | Binary   | Hex |
|---------|----------|-----|
| 0       | 00000000 | 00  |
| 65      | 01000001 | 41  |
| 255     | 11111111 | FF  |

A byte always maps to exactly two hex digits, making hex the preferred
notation in debuggers, memory dumps, and exploit analysis.

In NASM, hex literals use the 0x prefix:
```nasm
mov al, 0x41        ; load 65 (letter A) into AL
mov bx, 0xFF00      ; load a 16-bit value into BX
```

When reading a memory dump in GDB you will see rows of hex values.
Recognising patterns such as 0x41-0x5A for uppercase letters or
0x7F454C46 as the ELF file magic number is an essential skill.

---

## 4. ASCII Encoding

ASCII assigns a numeric code between 0 and 127 to each printable
character and several control codes. These values fit in one byte.

| Character | Decimal | Hex  | Binary   |
|-----------|---------|------|----------|
| 'A'       | 65      | 0x41 | 01000001 |
| 'Z'       | 90      | 0x5A | 01011010 |
| 'a'       | 97      | 0x61 | 01100001 |
| '0'       | 48      | 0x30 | 00110000 |
| newline   | 10      | 0x0A | 00001010 |
| space     | 32      | 0x20 | 00100000 |

A useful pattern: lowercase letters are exactly 32 (0x20) more than
their uppercase equivalents. Toggling bit 5 converts between cases —
a trick used in both optimisation and obfuscation.

In our data_demo.asm program the string "ABCDE" is stored in memory
as five consecutive bytes: 41 42 43 44 45 (hex). The CPU only sees
bytes — the terminal interprets them as characters when printed.

---

## 5. Two's Complement

Two's complement is how all modern x86/x64 CPUs represent negative
integers. For an n-bit number:

1. Positive numbers are stored in standard binary.
2. To negate: flip all bits, then add 1.

Example — representing -5 in 8 bits:
Step 1: Write +5 in binary  →  00000101
Step 2: Flip all bits        →  11111010
Step 3: Add 1                →  11111011  ← this is -5

Verification — adding +5 and -5 must equal 0:
00000101  (+5)

11111011  (-5)
──────────
100000000  → carry bit dropped → 00000000 = 0 ✓


This is why IDIV and IMUL (signed) exist alongside DIV and MUL
(unsigned) in x86 assembly, and why the overflow flag (OF) and
sign flag (SF) are critical for detecting arithmetic errors.

---

## 6. Little-Endian Memory Storage

When a multi-byte value is stored in memory there are two orderings:

- Big-endian: most significant byte at the lowest address
- Little-endian: least significant byte at the lowest address

All x86/x64 processors use little-endian storage.

Example — storing 0x12345678 starting at address 0x1000:

| Address | Big-endian | Little-endian |
|---------|-----------|---------------|
| 0x1000  | 0x12      | 0x78          |
| 0x1001  | 0x34      | 0x56          |
| 0x1002  | 0x56      | 0x34          |
| 0x1003  | 0x78      | 0x12          |

This means when NASM stores:
```nasm
word_val  dw  0x4142     ; in memory: 42 41
dword_val dd  0x41424344 ; in memory: 44 43 42 41
```

This is confirmed by our GDB inspection in data_demo where
x/2xb &word_val shows 0x42 0x41 — bytes reversed in memory.

---

## 7. Practical Relevance

| Field | Concept Applied |
|-------|----------------|
| Reverse engineering | Hex and ASCII to read strings from binaries |
| Exploit development | Endianness when injecting return addresses |
| Network forensics | Big-endian headers vs little-endian host values |
| Firmware analysis | Direct binary and hex reading of device memory |
| Cryptography | XOR and bit masking on raw bytes |
| Debugging | Two's complement overflow detection |

---

## 8. Conclusion

Binary, hexadecimal, ASCII, two's complement, and little-endian
storage are the language the CPU speaks internally. Every systems
programmer and security researcher must read memory dumps in hex,
convert between representations mentally, and understand how signed
arithmetic behaves at the bit level. The programs in this project
demonstrate these concepts running directly on real hardware with
no abstractions in between.

---
