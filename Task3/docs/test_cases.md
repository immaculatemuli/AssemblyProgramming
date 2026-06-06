File 4 of 5 — Task3/docs/test_cases.md
Run this:
bashnano Task3/docs/test_cases.md
Paste this in:
markdown# Test Cases — BIT 4220 Task 3: Marks Processor
## Boundary Mark Testing and Results

---

## 1. Classification Boundaries

The program classifies marks into four categories:

| Classification | Range   |
|---------------|---------|
| Distinction   | 70-100  |
| Credit        | 60-69   |
| Pass          | 40-59   |
| Fail          | 0-39    |

Boundary marks are the most important to test because they sit
exactly at the edge between two classifications. An off-by-one
error in a comparison instruction would misclassify these marks.

---

## 2. Boundary Mark Test Cases

### Test Array 1 — All Boundary Marks
marks db 0, 39, 40, 69, 70, 100, 50, 65, 75, 85

| Mark | Expected Class | Reason |
|------|---------------|--------|
| 0    | Fail          | Lowest possible mark |
| 39   | Fail          | Highest failing mark |
| 40   | Pass          | Lowest passing mark |
| 69   | Credit        | Highest credit mark |
| 70   | Distinction   | Lowest distinction mark |
| 100  | Distinction   | Highest possible mark |
| 50   | Pass          | Middle of pass range |
| 65   | Credit        | Middle of credit range |
| 75   | Distinction   | Middle of distinction range |
| 85   | Distinction   | Upper distinction range |

Expected output:
Total:   653
Average: 65
Highest: 100
Lowest:  0
--- Classifications ---
Distinctions (70-100): 4
Credits      (60-69):  2
Passes       (40-59):  2
Fails        (0-39):   2

---

### Test Array 2 — All Fails
marks db 0, 5, 10, 15, 20, 25, 30, 35, 38, 39

| Mark | Expected Class |
|------|---------------|
| All  | Fail          |

Expected output:
Total:   217
Average: 21
Highest: 39
Lowest:  0
--- Classifications ---
Distinctions (70-100): 0
Credits      (60-69):  0
Passes       (40-59):  0
Fails        (0-39):   10

---

### Test Array 3 — All Distinctions
marks db 70, 72, 75, 78, 80, 85, 88, 90, 95, 100

| Mark | Expected Class |
|------|---------------|
| All  | Distinction   |

Expected output:
Total:   833
Average: 83
Highest: 100
Lowest:  70
--- Classifications ---
Distinctions (70-100): 10
Credits      (60-69):  0
Passes       (40-59):  0
Fails        (0-39):   0

---

### Test Array 4 — Default Program Array
marks db 45, 78, 90, 32, 67, 55, 88, 71, 40, 95

| Mark | Expected Class |
|------|---------------|
| 45   | Pass          |
| 78   | Distinction   |
| 90   | Distinction   |
| 32   | Fail          |
| 67   | Credit        |
| 55   | Pass          |
| 88   | Distinction   |
| 71   | Distinction   |
| 40   | Pass          |
| 95   | Distinction   |

Expected output:
Total:   661
Average: 66
Highest: 95
Lowest:  32
--- Classifications ---
Distinctions (70-100): 5
Credits      (60-69):  1
Passes       (40-59):  3
Fails        (0-39):   1

---

## 3. How to Run Each Test

To test a different array, open the source file and change
the marks line:

```bash
nano Task3/asm/marks_processor.asm
```

Find this line:
```nasm
marks db 45, 78, 90, 32, 67, 55, 88, 71, 40, 95
```

Replace with your test array, save, then rebuild:
```bash
cd Task3
make clean
make
./marks_processor
```

---

## 4. Boundary Condition Analysis

### Why 39 and 40 Are Critical
```nasm
cmp rax, 40         ; compare mark with 40
jl .check_fail      ; if mark < 40 jump to fail
```

The instruction `jl` means "jump if less than". So:
- mark = 40 → condition false → stays in pass range ✓
- mark = 39 → condition true  → jumps to fail ✓
- mark = 41 → condition false → stays in pass range ✓

If we had used `jle` (jump if less than or equal) instead:
- mark = 40 → condition true → wrongly classified as fail ✗

This is why boundary testing matters in assembly.

---

### Why 69 and 70 Are Critical
```nasm
cmp rax, 70         ; compare mark with 70
jl .check_credit    ; if mark < 70 jump to credit check
```

- mark = 70 → condition false → stays in distinction ✓
- mark = 69 → condition true  → goes to credit check ✓

---

## 5. GDB Testing of Boundary Marks

To inspect classification logic in GDB:

```bash
gdb ./marks_processor
(gdb) break .classify_loop
(gdb) run
(gdb) info registers rax rcx r10 r11 r12 r13
```

Watch how r10 (distinctions), r11 (credits), r12 (passes),
r13 (fails) increment as each mark is processed.

Step through one iteration:
```bash
(gdb) stepi
(gdb) info registers rax     # current mark being classified
(gdb) info registers r10 r11 r12 r13  # classification counts
```

---

## 6. Summary of All Tests

| Test | Array Description    | D  | C  | P  | F  | Total | Avg |
|------|---------------------|----|----|----|----|-------|-----|
| 1    | Boundary marks      | 4  | 2  | 2  | 2  | 653   | 65  |
| 2    | All fails           | 0  | 0  | 0  | 10 | 217   | 21  |
| 3    | All distinctions    | 10 | 0  | 0  | 0  | 833   | 83  |
| 4    | Default array       | 5  | 1  | 3  | 1  | 661   | 66  |

---
