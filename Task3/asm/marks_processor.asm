; ============================================================
; marks_processor.asm — BIT 4220 Task 3
; Processes student marks stored in memory
; Demonstrates: immediate, register, direct, indirect,
;               indexed and based addressing modes
;
; Build:
;   nasm -f elf64 marks_processor.asm -o marks_processor.o
;   ld marks_processor.o -o marks_processor
; Run:
;   ./marks_processor
; ============================================================

section .data

    ; ---- Array of 10 student marks ----
    ; Direct addressing: marks is a fixed memory label
    ; Each mark is 1 byte (db)
    marks       db  45, 78, 90, 32, 67, 55, 88, 71, 40, 95
    marks_count equ 10          ; Immediate value — number of marks

    ; ---- Header messages ----
    hdr         db  0x0A
                db  "=====================================", 0x0A
                db  "   MARKS PROCESSOR — BIT 4220       ", 0x0A
                db  "=====================================", 0x0A
    hdr_len     equ $ - hdr

    marks_label db  "Marks in memory: "
    marks_label_len equ $ - marks_label

    newline     db  0x0A
    newline_len equ $ - newline

    space       db  " "
    space_len   equ $ - space

    ; ---- Result labels ----
    lbl_total   db  0x0A, "Total:   "
    lbl_total_len equ $ - lbl_total

    lbl_avg     db  0x0A, "Average: "
    lbl_avg_len equ $ - lbl_avg

    lbl_high    db  0x0A, "Highest: "
    lbl_high_len equ $ - lbl_high

    lbl_low     db  0x0A, "Lowest:  "
    lbl_low_len equ $ - lbl_low

    lbl_class   db  0x0A, 0x0A, "--- Classifications ---", 0x0A
    lbl_class_len equ $ - lbl_class

    lbl_dist    db  "Distinctions (70-100): "
    lbl_dist_len equ $ - lbl_dist

    lbl_credit  db  "Credits      (60-69):  "
    lbl_credit_len equ $ - lbl_credit

    lbl_pass    db  "Passes       (40-59):  "
    lbl_pass_len equ $ - lbl_pass

    lbl_fail    db  "Fails        (0-39):   "
    lbl_fail_len equ $ - lbl_fail

    footer      db  0x0A, "=====================================", 0x0A
    footer_len  equ $ - footer

    ; ---- Addressing mode demonstration messages ----
    addr_hdr    db  0x0A, "--- Addressing Modes Used ---", 0x0A
    addr_hdr_len equ $ - addr_hdr

    addr_imm    db  "Immediate: marks_count = 10 (value in instruction)", 0x0A
    addr_imm_len equ $ - addr_imm

    addr_reg    db  "Register:  mov rbx, rax (value from register)", 0x0A
    addr_reg_len equ $ - addr_reg

    addr_dir    db  "Direct:    [marks] (fixed memory label)", 0x0A
    addr_dir_len equ $ - addr_dir

    addr_ind    db  "Indirect:  [rbx] (address in register)", 0x0A
    addr_ind_len equ $ - addr_ind

    addr_idx    db  "Indexed:   [marks + rcx*1] (base + index)", 0x0A
    addr_idx_len equ $ - addr_idx

    addr_based  db  "Based:     [rbx + 1] (base register + offset)", 0x0A
    addr_based_len equ $ - addr_based

section .bss
    result_buf  resb 16     ; buffer for printing numbers

section .text
    global _start

; ============================================================
; MACROS
; ============================================================
%macro PRINT 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

; ============================================================
; print_number: prints integer in rax to stdout
; ============================================================
print_number:
    push rbx
    push rcx
    push rdx
    push r8

    mov rbx, result_buf
    mov rcx, 0

    ; Handle zero
    test rax, rax
    jnz .nonzero
    mov byte [rbx], '0'
    mov byte [rbx+1], 0x0A
    mov rax, 1
    mov rdi, 1
    mov rsi, result_buf
    mov rdx, 2
    syscall
    jmp .done

.nonzero:
    xor r8, r8
.extract:
    xor rdx, rdx
    mov rcx, 10
    div rcx
    push rdx
    inc r8
    test rax, rax
    jnz .extract

.build:
    pop rdx
    add dl, '0'
    mov [rbx], dl
    inc rbx
    dec r8
    jnz .build

    mov byte [rbx], 0x0A
    inc rbx

    mov rax, 1
    mov rdi, 1
    mov rsi, result_buf
    mov rdx, rbx
    sub rdx, result_buf
    syscall

.done:
    pop r8
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================
; print_byte: prints a single byte value as decimal
; ============================================================
print_byte:
    push rax
    movzx rax, al          ; zero extend byte to 64-bit
    call print_number
    pop rax
    ret

; ============================================================
; MAIN PROGRAM
; ============================================================
_start:

    ; ---- Print header ----
    PRINT hdr, hdr_len

    ; ---- Print all marks ----
    ; Uses INDEXED addressing: [marks + rcx*1]
    PRINT marks_label, marks_label_len

    mov rcx, 0                  ; index = 0 (immediate addressing)

.print_marks_loop:
    ; INDEXED addressing mode: base address + index register
    movzx rax, byte [marks + rcx]   ; load mark at marks[rcx]
    call print_number

    PRINT space, space_len

    inc rcx                     ; increment index (register addressing)
    cmp rcx, marks_count        ; compare with immediate value 10
    jl .print_marks_loop

    PRINT newline, newline_len

    ; ============================================================
    ; COMPUTE TOTAL
    ; Uses: direct addressing for base, indexed for each element
    ; ============================================================
    mov rax, 0                  ; total = 0 (immediate addressing)
    mov rcx, 0                  ; index = 0

.total_loop:
    ; INDEXED addressing: marks + rcx*1
    movzx rbx, byte [marks + rcx]   ; load marks[rcx]
    add rax, rbx                     ; total += marks[rcx]
    inc rcx
    cmp rcx, marks_count
    jl .total_loop

    mov r14, rax                ; save total in r14

    ; Print total
    PRINT lbl_total, lbl_total_len
    mov rax, r14
    call print_number

    ; ============================================================
    ; COMPUTE AVERAGE
    ; ============================================================
    mov rax, r14                ; rax = total
    xor rdx, rdx                ; clear rdx for division
    mov rcx, marks_count        ; divide by 10 (immediate)
    div rcx                     ; rax = average
    mov r15, rax                ; save average in r15

    PRINT lbl_avg, lbl_avg_len
    mov rax, r15
    call print_number

    ; ============================================================
    ; FIND HIGHEST MARK
    ; Uses: indirect addressing via rbx pointer
    ; ============================================================
    ; DIRECT addressing: load address of marks array
    mov rbx, marks              ; rbx points to start of marks array
    movzx rax, byte [rbx]       ; INDIRECT: load first mark via pointer
    mov r8, rax                 ; r8 = current highest

    mov rcx, 1                  ; start from index 1

.highest_loop:
    ; BASED addressing: rbx (base) + rcx (index)
    movzx rax, byte [rbx + rcx]     ; load marks[rcx] via based addressing
    cmp rax, r8
    jle .not_higher
    mov r8, rax                      ; update highest (register addressing)
.not_higher:
    inc rcx
    cmp rcx, marks_count
    jl .highest_loop

    PRINT lbl_high, lbl_high_len
    mov rax, r8
    call print_number

    ; ============================================================
    ; FIND LOWEST MARK
    ; Uses: based addressing [rbx + rcx]
    ; ============================================================
    mov rbx, marks
    movzx rax, byte [rbx]       ; INDIRECT: load first mark
    mov r9, rax                 ; r9 = current lowest

    mov rcx, 1

.lowest_loop:
    movzx rax, byte [rbx + rcx] ; BASED addressing: base + offset
    cmp rax, r9
    jge .not_lower
    mov r9, rax
.not_lower:
    inc rcx
    cmp rcx, marks_count
    jl .lowest_loop

    PRINT lbl_low, lbl_low_len
    mov rax, r9
    call print_number

    ; ============================================================
    ; CLASSIFY MARKS
    ; Distinction: 70-100
    ; Credit:      60-69
    ; Pass:        40-59
    ; Fail:        0-39
    ; ============================================================
    PRINT lbl_class, lbl_class_len

    mov r10, 0      ; distinction counter
    mov r11, 0      ; credit counter
    mov r12, 0      ; pass counter
    mov r13, 0      ; fail counter
    mov rcx, 0      ; index

.classify_loop:
    ; INDEXED addressing: marks + rcx
    movzx rax, byte [marks + rcx]

    ; Check Distinction (70-100)
    cmp rax, 70
    jl .check_credit
    inc r10
    jmp .next_mark

    ; Check Credit (60-69)
.check_credit:
    cmp rax, 60
    jl .check_pass
    inc r11
    jmp .next_mark

    ; Check Pass (40-59)
.check_pass:
    cmp rax, 40
    jl .check_fail
    inc r12
    jmp .next_mark

    ; Fail (0-39)
.check_fail:
    inc r13

.next_mark:
    inc rcx
    cmp rcx, marks_count
    jl .classify_loop

    ; Print classification counts
    PRINT lbl_dist, lbl_dist_len
    mov rax, r10
    call print_number

    PRINT lbl_credit, lbl_credit_len
    mov rax, r11
    call print_number

    PRINT lbl_pass, lbl_pass_len
    mov rax, r12
    call print_number

    PRINT lbl_fail, lbl_fail_len
    mov rax, r13
    call print_number

    ; ============================================================
    ; ADDRESSING MODES SUMMARY
    ; ============================================================
    PRINT addr_hdr,   addr_hdr_len
    PRINT addr_imm,   addr_imm_len
    PRINT addr_reg,   addr_reg_len
    PRINT addr_dir,   addr_dir_len
    PRINT addr_ind,   addr_ind_len
    PRINT addr_idx,   addr_idx_len
    PRINT addr_based, addr_based_len

    ; Print footer
    PRINT footer, footer_len

    ; Exit
    mov rax, 60
    mov rdi, 0
    syscall
