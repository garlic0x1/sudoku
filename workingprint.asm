global _start

section .data
  board db 0, 0, 0, 9, 0, 4, 0, 0, 1,
        db 0, 2, 0, 3, 0, 0, 0, 5, 0,
        db 9, 0, 6, 0, 0, 0, 0, 0, 0,
        db 8, 0, 0, 0, 4, 6, 0, 0, 0,
        db 4, 0, 0, 0, 1, 0, 0, 0, 3,
        db 0, 0, 0, 2, 7, 0, 0, 0, 5,
        db 0, 0, 0, 0, 0, 0, 9, 0, 7,
        db 0, 7, 0, 0, 0, 5, 0, 1, 0,
        db 3, 0, 0, 4, 0, 7, 0, 0, 0

  msg equ board
  len equ $ - msg

section .text
_start:
  ;mov ax, 0
  ;main:
  ;movzx eax, ax
  ;push eax
  ;push dword format
  ;call printf
  ;inc ax
  ;jmp main
  ;mov eax, 4
  ;mov ebx, 1
  ;mov ecx, msg
  ;mov edx, len
  ;int 0x80
  call printboard
  mov eax, 1
  mov ebx, 0
  int 0x80

printboard:
  push ebp ; preserve ebp by pushing to stack
  mov ebp, esp
  sub esp, 2  ; last line of prologue

  xor esi, esi ; loop counter
  mov edi, board ; board pointer

  loop:
    mov ecx, [edi]
    inc edi
    add ecx, '0'
    mov [esp], ecx

    mov eax, 4  ; sys_write system call
    mov ebx, 1  ; stdout file descriptor
    mov ecx, esp; bytes to write
    mov edx, 1  ; length to write
    int 0x80   ; sys call

    inc esi

    cmp esi, 81
    jl loop

  mov esp, ebp; first line of epilogue
  pop ebp ; return ebp to former state
  ret
