; ============================================================
; alu_simulator.asm — BIT 4220 Task 2: ALU Simulator
; Simulates a prepaid meter computation module
; Demonstrates: ADD, SUB, MUL, DIV, AND, OR, XOR, NOT
;               carry, zero, sign and overflow flags
;               ASCII input conversion, menu-driven interface
;
; Build:
;   nasm -f elf64 alu_simulator.asm -o alu_simulator.o
;   ld alu_simulator.o -o alu_simulator
; Run:
;   ./alu_simulator
; ============================================================

section .data

    ; --- Menu and prompts ---
    menu        db  0x0A
                db  "================================", 0x0A
                db  "   ALU SIMULATOR — BIT 4220    ", 0x0A
                db  "   Prepaid Meter Module         ", 0x0A
                db  "================================", 0x0A
                db  "1. ADD  (add units)             ", 0x0A
                db  "2. SUB  (subtract usage)        ", 0x0A
                db  "3. MUL  (multiply rate)         ", 0x0A
                db  "4. DIV  (divide balance)        ", 0x0A
                db  "5. AND  (bit mask status)       ", 0x0A
                db  "6. OR   (set status bits)       ", 0x0A
                db  "7. XOR  (toggle status bits)    ", 0x0A
                db  "8. NOT  (invert bits)           ", 0x0A
                db  "9. EXIT                         ", 0x0A
                db  "================================", 0x0A
    menu_len    equ $ - menu

    prompt1     db  "Enter first number (0-9): "
    prompt1_len equ $ - prompt1

    prompt2     db  "Enter second number (0-9): "
    prompt2_len equ $ - prompt2

    choice_msg  db  "Choose option (1-9): "
    choice_len  equ $ - choice_msg

    result_msg  db  "Result: "
    result_len  equ $ - result_msg

    newline     db  0x0A
    newline_len equ $ - newline

    ; --- Operation labels ---
    op_add      db  "Operation: ADD", 0x0A
    op_add_len  equ $ - op_add

    op_sub      db  "Operation: SUB", 0x0A
    op_sub_len  equ $ - op_sub

    op_mul      db  "Operation: MUL", 0x0A
    op_mul_len  equ $ - op_mul

    op_div      db  "Operation: DIV", 0x0A
    op_div_len  equ $ - op_div

    op_and      db  "Operation: AND", 0x0A
    op_and_len  equ $ - op_and

    op_or       db  "Operation: OR", 0x0A
    op_or_len   equ $ - op_or

    op_xor      db  "Operation: XOR", 0x0A
    op_xor_len  equ $ - op_xor

    op_not      db  "Operation: NOT (on first number only)", 0x0A
    op_not_len  equ $ - op_not

    bye_msg     db  "Exiting ALU Simulator. Goodbye!", 0x0A
    bye_len     equ $ - bye_msg

    err_msg     db  "Invalid choice. Please enter 1-9.", 0x0A
    err_len     equ $ - err_msg

    overflow_msg db "WARNING: Overflow detected!", 0x0A
    overflow_len equ $ - overflow_msg

section .bss
    ; Reserve space for user input (uninitialized)
    num1_buf    resb 4      ; buffer for first number input
    num2_buf    resb 4      ; buffer for second number input
    choice_buf  resb 4      ; buffer for menu choice input
    result_buf  resb 32     ; buffer for result output

; ============================================================
; MACROS
; ============================================================

; Print a message: PRINT label, length
%macro PRINT 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

; Read input from keyboard: READ buffer, length
%macro READ 2
    mov rax, 0          ; syscall 0 = sys_read
    mov rdi, 0          ; fd 0 = stdin
    mov rsi, %1         ; buffer to store input
    mov rdx, %2         ; max bytes to read
    syscall
%endmacro

section .text
    global _start

; ============================================================
; HELPER: print_result
; Converts value in rax to ASCII digit(s) and prints it
; Handles values 0-99
; ============================================================
print_result:
    ; Save registers
    push rbx
    push rcx
    push rdx

    mov rbx, result_buf     ; point to result buffer
    mov rcx, 0              ; digit counter

    ; Handle negative results — check sign flag
    test rax, rax
    jge  .positive
    ; Print minus sign
    mov byte [rbx], '-'
    inc rbx
    neg rax                 ; make positive for digit extraction

.positive:
    ; Extract digits (handles 0-999)
    mov rcx, 10
    xor r8, r8              ; digit count

.extract_loop:
    xor rdx, rdx
    div rcx                 ; rax = quotient, rdx = remainder (digit)
    push rdx                ; push digit onto stack
    inc r8
    test rax, rax
    jnz .extract_loop

.print_digits:
    pop rdx                 ; pop digit
    add dl, '0'             ; convert to ASCII
    mov [rbx], dl
    inc rbx
    dec r8
    jnz .print_digits

    ; Add newline
    mov byte [rbx], 0x0A
    inc rbx

    ; Print the result buffer
    mov rax, 1
    mov rdi, 1
    mov rsi, result_buf
    mov rdx, rbx
    sub rdx, result_buf
    syscall

    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================
; MAIN PROGRAM
; ============================================================
_start:

.menu_loop:
    ; Print menu
    PRINT menu, menu_len

    ; Get first number
    PRINT prompt1, prompt1_len
    READ  num1_buf, 4

    ; Get second number
    PRINT prompt2, prompt2_len
    READ  num2_buf, 4

    ; Get menu choice
    PRINT choice_msg, choice_len
    READ  choice_buf, 4

    ; Convert ASCII input to integers
    ; ASCII '5' = 53, so subtract 48 ('0') to get 5
    movzx rax, byte [num1_buf]
    sub   rax, '0'          ; num1 now in rax
    mov   r12, rax          ; save num1 in r12

    movzx rax, byte [num2_buf]
    sub   rax, '0'          ; num2 now in rax
    mov   r13, rax          ; save num2 in r13

    ; Read choice
    movzx rax, byte [choice_buf]
    sub   rax, '0'          ; convert choice to number

    ; ---- Dispatch to operation ----
    cmp rax, 1
    je  .do_add
    cmp rax, 2
    je  .do_sub
    cmp rax, 3
    je  .do_mul
    cmp rax, 4
    je  .do_div
    cmp rax, 5
    je  .do_and
    cmp rax, 6
    je  .do_or
    cmp rax, 7
    je  .do_xor
    cmp rax, 8
    je  .do_not
    cmp rax, 9
    je  .do_exit

    ; Invalid choice
    PRINT err_msg, err_len
    jmp .menu_loop

; ---- ADD ----
; Adds num1 + num2
; Flags: CF set if carry out, ZF set if result=0
.do_add:
    PRINT op_add, op_add_len
    mov rax, r12            ; rax = num1
    add rax, r13            ; rax = num1 + num2
    PRINT result_msg, result_len
    call print_result
    jmp .menu_loop

; ---- SUB ----
; Subtracts num2 from num1
; Flags: CF set if borrow, SF set if result negative
.do_sub:
    PRINT op_sub, op_sub_len
    mov rax, r12            ; rax = num1
    sub rax, r13            ; rax = num1 - num2
    PRINT result_msg, result_len
    call print_result
    jmp .menu_loop

; ---- MUL ----
; Multiplies num1 * num2 (unsigned)
; Result stored in rax (low) and rdx (high)
.do_mul:
    PRINT op_mul, op_mul_len
    mov rax, r12            ; rax = num1
    mul r13                 ; rdx:rax = num1 * num2
    PRINT result_msg, result_len
    call print_result
    jmp .menu_loop

; ---- DIV ----
; Divides num1 / num2 (unsigned)
; rax = quotient, rdx = remainder
.do_div:
    PRINT op_div, op_div_len
    mov rax, r12            ; rax = num1 (dividend)
    xor rdx, rdx            ; clear rdx (required before div)
    cmp r13, 0              ; check for division by zero
    je  .div_zero
    div r13                 ; rax = quotient
    PRINT result_msg, result_len
    call print_result
    jmp .menu_loop

.div_zero:
    mov rax, 1
    mov rdi, 1
    mov rsi, err_msg
    mov rdx, err_len
    syscall
    jmp .menu_loop

; ---- AND ----
; Bitwise AND — used for masking device status bits
; Example: 0b1111 AND 0b1010 = 0b1010 (isolate bits)
.do_and:
    PRINT op_and, op_and_len
    mov rax, r12
    and rax, r13            ; rax = num1 AND num2
    PRINT result_msg, result_len
    call print_result
    jmp .menu_loop

; ---- OR ----
; Bitwise OR — used to set specific status bits
; Example: 0b0000 OR 0b1010 = 0b1010 (set bits)
.do_or:
    PRINT op_or, op_or_len
    mov rax, r12
    or  rax, r13            ; rax = num1 OR num2
    PRINT result_msg, result_len
    call print_result
    jmp .menu_loop

; ---- XOR ----
; Bitwise XOR — used to toggle status bits
; Example: 0b1111 XOR 0b1010 = 0b0101 (flip bits)
.do_xor:
    PRINT op_xor, op_xor_len
    mov rax, r12
    xor rax, r13            ; rax = num1 XOR num2
    PRINT result_msg, result_len
    call print_result
    jmp .menu_loop

; ---- NOT ----
; Bitwise NOT — inverts all bits of num1
; Example: NOT 0b00000101 = 0b11111010
.do_not:
    PRINT op_not, op_not_len
    mov rax, r12
    not rax                 ; flip all 64 bits
    and rax, 0xFF           ; mask to 8 bits for readable output
    PRINT result_msg, result_len
    call print_result
    jmp .menu_loop

; ---- EXIT ----
.do_exit:
    PRINT bye_msg, bye_len
    mov rax, 60
    mov rdi, 0
    syscall
