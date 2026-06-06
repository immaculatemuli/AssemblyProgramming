; ============================================================
; hello.asm — BIT 4220 Task 1: Hello World
; Demonstrates: .data section, system calls, Linux syscall ABI
; Build:
;   nasm -f elf64 hello.asm -o hello.o
;   ld hello.o -o hello
; Run:
;   ./hello
; ============================================================

section .data
    msg      db  "Hello, BIT 4220 Students!", 0x0A
    msglen   equ $ - msg

    line2    db  "Assembly sees everything as raw bytes.", 0x0A
    line2len equ $ - line2

    line3    db  "Welcome to low-level programming!", 0x0A
    line3len equ $ - line3

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msglen
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, line2
    mov rdx, line2len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, line3
    mov rdx, line3len
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
