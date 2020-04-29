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

  newline db 0xA, 0xD

  separator db '|'
  separatorlen equ $-separator

  line db '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', 0xA, 0xD

  msg equ board
  len equ $ - msg


section .text

_start:
  call printboard
  call solve
  ;push 6 ; n
  ;push 0 ; pos

  ;mov eax, 9
  ;call possible
  mov ebx, eax
  mov eax, 1
  ;mov ebx, 0
  int 0x80

solve:
  push ebp
  push ebx
  mov ebp, esp

  call printboard
  xor cx, cx
  mov cx, 0 ; loop counter = 0
  solve1:
  push cx

    mov ebx, board
    add ebx, ecx
    mov ax, [ebx]
    cmp ax, 0
    jne skips1

    mov cx, 1
    solve2:

    push cx      ; push n.  pos was pushed at the beginning of solve1
    call possible
    debug1:
    pop cx
    cmp eax, 0
    je skips2     ; if possible:

      mov ebx, [esp+4]  ; ebx = the outer loop counter, pos
      add ebx, board
      mov ax, cx
      mov [bx], al     ; byte board[i] = n
      push ebx
      push cx
      call solve
      pop cx
      pop ebx
      cmp eax, 1
      je ret1
      mov ax, 0
      mov [bx], al

    skips2:       ; else:


    inc cx
    cmp cx, 0xa
    jl solve2

    jmp ret0

  push cx
  call printboard
  pop cx
  skips1:
  pop cx
  inc cx
  cmp cx, 81
  jl solve1

  ret0:
  mov eax, 0
  mov esp, ebp; first line of epilogue
  pop ebx
  pop ebp ; return ebp to former state
  ret

  ret1:
  mov eax, 1
  mov esp, ebp; first line of epilogue
  pop ebx
  pop ebp ; return ebp to former state
  ret

possible: ; int possible(pos, n)
  push ebp
  push ebx
  mov ebp, esp

  sub esp, 8 ; allocate two variables on the stack

  mov eax, [ebp+12]   ; ebx = pos
  mov ebx, 0x9
  div ebx
  mov dword [ebp-4], eax ; int row = pos / 9
  mov dword [ebp-8], edx ; int col = pos % 9

  mov ecx, 0x0  ; for (i in 0..8)
  possible1:  ; iterating through rows, columns and squares
  push ecx    ; save ecx to be loop counter

  ; break loop and return 0 if match in row

  mov eax, dword [ebp-4]  ; eax = row
  mov ebx, 0x9
  mul ebx                 ; eax *= 9
  mov ebx, board          ; ebx = board
  add ebx, eax            ; ebx += (row*9)
  add ebx, ecx            ; ebx += i
  mov ax, [ebx]          ; ebx = value at ebx
  mov bx, [ebp+16]
  cmp ax, bx
  je impossible           ; if ebx == num

  ; break loop and return 0 if match in col
  mov eax, 0x9
  mul ecx                 ; eax = 9 * ecx
  mov edx, dword [ebp-8]  ; edx = col
  mov ebx, board          ; ebx = board
  add ebx, eax            ; ebx += (loop*9)
  add ebx, edx            ; ebx += col
  mov ax, [ebx]          ; ebx = value at ebx
  mov bx, [ebp+16]
  cmp ax, bx
  je impossible           ; if ebx == num

  ; break loop and return 0 if match in square
  push edi
  push esi
  push eax
  push ebx
  push ecx
  push edx

  mov eax, dword [ebp-4]  ; eax = row
  cmp eax, 0x0
  je skip1
  mov ebx, 0x3            ; ebx = 3
  xor edx, edx
  div ebx                 ; eax = eax / 3
  mul ebx                 ; eax = eax * 3
  mov ebx, 0x9
  mul ebx                 ; eax *= 9
  skip1:
  push eax                ; save eax to the stack

  mov eax, dword [ebp-8]  ; eax = col
  cmp eax, 0x0
  je skip2
  mov ebx, 0x3            ; ebx = 3
  xor edx, edx
  div ebx                 ; eax = eax / 3
  mul ebx                 ; eax = eax * 3
  skip2:
  push eax                ; save eax to the stack

  mov eax, ecx            ; eax = i
  cmp eax, 0x0
  mov ebx, 0x3
  xor edx, edx
  div ebx                 ; eax /= 3
  push edx                ;save edx to stack
  mov ebx, 0x9
  mul ebx                 ; eax *= 9
  push eax                ; save eax

  pop eax
  pop ebx
  pop ecx
  pop edx
  mov edi, board          ; edi = board
  add edi, eax
  add edi, ebx
  add edi, ecx
  add edi, edx

  mov ax, [edi]          ; ebx = value at ebx
  mov bx, [ebp+16]
  cmp ax, bx
  je impossible           ; if ebx == num

  pop edx
  pop ecx
  pop ebx
  pop eax
  pop esi
  pop edi

  pop ecx
  inc ecx
  cmp ecx, 9
  jl possible1

  mov eax, 1
  mov esp, ebp
  pop ebx
  pop ebp
  ret

  impossible:
  mov eax, 0
  mov esp, ebp
  pop ebx
  pop ebp
  ret

printboard:
  push ebp ; preserve ebp by pushing to stack
  push ebx
  mov ebp, esp

  xor esi, esi ; loop counter
  mov edi, board ; board pointer

  loop:
    inc esi

    xor edx, edx ; if not esi % 9 == 0, skipnewline
    mov eax, esi
    dec eax
    mov ecx, 9
    div ecx
    cmp edx, 0
    jne skipnewline


    mov eax, 4  ; sys_write system call
    mov ebx, 1  ; stdout file descriptor
    mov ecx, newline; bytes to write
    mov edx, 2  ; length to write
    int 0x80   ; sys call

    xor edx, edx ; if not esi % 27 == 0, skipnewline
    mov eax, esi
    dec eax
    mov ecx, 27
    div ecx
    cmp edx, 0
    jne printnum

    mov eax, 4
    mov ebx, 1
    mov ecx, line
    mov edx, 13
    int 0x80

    jmp printnum ; dont print a separator

    skipnewline:

    xor edx, edx
    mov eax, esi
    dec eax
    mov ecx, 3
    div ecx
    cmp edx, 0
    jne printnum

    mov eax, 4
    mov ebx, 1
    mov ecx, separator
    mov edx, separatorlen
    int 0x80

    printnum:
    mov ecx, [edi]
    inc edi
    add ecx, '0'
    mov [esp], ecx

    mov eax, 4  ; sys_write system call
    mov ebx, 1  ; stdout file descriptor
    mov ecx, esp; bytes to write
    mov edx, 1  ; length to write
    int 0x80   ; sys call


    cmp esi, 81
    jl loop

  mov eax, 4  ; sys_write system call
  mov ebx, 1  ; stdout file descriptor
  mov ecx, newline; bytes to write
  mov edx, 2  ; length to write
  int 0x80   ; sys call
  mov eax, 4  ; sys_write system call
  mov ebx, 1  ; stdout file descriptor
  mov ecx, newline; bytes to write
  mov edx, 2  ; length to write
  int 0x80

  mov esp, ebp; first line of epilogue
  pop ebx
  pop ebp ; return ebp to former state
  ret
