; 8088/8086 test suite for ADD opcodes
; NASM, org 0x100 -> flat .COM output
bits 16
org 0x100

start:
    ; Ensure DS = CS (so data references work)
    push cs
    pop ds

    ; Run tests
    call test_add_rm8_r8      ; ADD r/m8, r8
    call test_add_rm16_r16    ; ADD r/m16, r16
    call test_add_r8_rm8      ; ADD r8, r/m8
    call test_add_r16_rmem    ; ADD r16, r/m16
    call test_add_al_d8       ; ADD AL, d8
    call test_add_ax_d16      ; ADD AX, d16

    ; Done
    mov dx, msg_done
    mov ah, 9
    int 21h

    mov ax, 4C00h
    int 21h

; ---------------------------------------------------------------------------
; Constants for flag masks and expected values
; Mask for OF, SF, ZF, AF, PF, CF  = bits 11,7,6,4,2,0  => 0x0800|0x0080|0x0040|0x0010|0x0004|0x0001 = 0x08D5
flag_mask      equ 0x08D5

; ---------------------------------------------------------------------------
; Test 1: ADD r/m8, r8
; Setup: byte mem_rm8 = 0xFF, AL = 0x01, do ADD [mem_rm8], AL
; Expect result 0x00 and flags: OF=0 S=0 Z=1 A=1 P=1 C=1  => expected_flags = 0x0055
test_add_rm8_r8:
    mov byte [mem_rm8], 0FFh
    mov al, 1
    lea si, [mem_rm8]
    add byte [si], al           ; ADD r/m8, r8 (00 /r)
    ; check result
    mov al, [mem_rm8]
    cmp al, 0
    jne .t1_fail
    ; check flags
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask
    cmp bx, 0x0055
    jne .t1_fail
    mov dx, test1_pass
    jmp .t1_print
.t1_fail:
    mov dx, test1_fail
.t1_print:
    mov ah, 9
    int 21h
    ret

; ---------------------------------------------------------------------------
; Test 2: ADD r/m16, r16
; Setup: word mem_rm16 = 0xFFFF, BX = 1, do ADD [mem_rm16], BX
; Expect result 0x0000 and flags: OF=0 S=0 Z=1 A=1 P=1 C=1 => 0x0055
test_add_rm16_r16:
    mov word [mem_rm16], 0FFFFh
    mov bx, 1
    lea si, [mem_rm16]
    add word [si], bx          ; ADD r/m16, r16 (01 /r)
    ; check result
    mov ax, [mem_rm16]
    cmp ax, 0
    jne .t2_fail
    ; check flags
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask
    cmp bx, 0x0055
    jne .t2_fail
    mov dx, test2_pass
    jmp .t2_print
.t2_fail:
    mov dx, test2_fail
.t2_print:
    mov ah, 9
    int 21h
    ret

; ---------------------------------------------------------------------------
; Test 3: ADD r8, r/m8
; Setup: byte mem_r8src = 0xFF, AL = 0x01, do ADD AL, [mem_r8src]
; Expect AL=0x00 and same flags as test1 => 0x0055
test_add_r8_rm8:
    mov byte [mem_r8src], 0FFh
    mov al, 1
    lea si, [mem_r8src]
    add al, [si]               ; ADD r8, r/m8 (02 /r)
    ; check result
    cmp al, 0
    jne .t3_fail
    ; check flags
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask
    cmp bx, 0x0055
    jne .t3_fail
    mov dx, test3_pass
    jmp .t3_print
.t3_fail:
    mov dx, test3_fail
.t3_print:
    mov ah, 9
    int 21h
    ret

; ---------------------------------------------------------------------------
; Test 4: ADD r16, r/m16
; Setup: word mem_r16src = 0xFFFF, AX = 1, do ADD AX, [mem_r16src]
; Expect AX=0x0000 and same flags => 0x0055
test_add_r16_rmem:
    mov word [mem_r16src], 0FFFFh
    mov ax, 1
    lea si, [mem_r16src]
    add ax, [si]               ; ADD r16, r/m16 (03 /r)
    ; check result
    cmp ax, 0
    jne .t4_fail
    ; check flags
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask
    cmp bx, 0x0055
    jne .t4_fail
    mov dx, test4_pass
    jmp .t4_print
.t4_fail:
    mov dx, test4_fail
.t4_print:
    mov ah, 9
    int 21h
    ret

; ---------------------------------------------------------------------------
; Test 5: ADD AL, d8
; Setup: AL = 0x7F, add 0x01 -> AL = 0x80 -> Expect OF=1 SF=1 ZF=0 AF=1 PF=0 CF=0 => expected 0x0890
test_add_al_d8:
    mov al, 7Fh
    add al, 01h                ; ADD AL, imm8 (04 ib)
    cmp al, 080h
    jne .t5_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask
    cmp bx, 0x0890
    jne .t5_fail
    mov dx, test5_pass
    jmp .t5_print
.t5_fail:
    mov dx, test5_fail
.t5_print:
    mov ah, 9
    int 21h
    ret

; ---------------------------------------------------------------------------
; Test 6: ADD AX, d16
; Setup: AX = 0x7FFF, add 1 -> AX = 0x8000 -> Expect OF=1 SF=1 ZF=0 AF=1 PF=1 CF=0 => expected 0x0894
test_add_ax_d16:
    mov ax, 7FFFh
    add ax, 1                  ; ADD AX, imm16 (05 iw)
    cmp ax, 08000h
    jne .t6_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask
    cmp bx, 0x0894
    jne .t6_fail
    mov dx, test6_pass
    jmp .t6_print
.t6_fail:
    mov dx, test6_fail
.t6_print:
    mov ah, 9
    int 21h
    ret

; ---------------------------------------------------------------------------
; Data area (strings and test memory)
mem_rm8:     db 0
mem_rm16:    dw 0
mem_r8src:   db 0
mem_r16src:  dw 0

test1_pass:  db 'ADD r/m8, r8: PASS',0Dh,0Ah,'$'
test1_fail:  db 'ADD r/m8, r8: FAIL',0Dh,0Ah,'$'

test2_pass:  db 'ADD r/m16, r16: PASS',0Dh,0Ah,'$'
test2_fail:  db 'ADD r/m16, r16: FAIL',0Dh,0Ah,'$'

test3_pass:  db 'ADD r8, r/m8: PASS',0Dh,0Ah,'$'
test3_fail:  db 'ADD r8, r/m8: FAIL',0Dh,0Ah,'$'

test4_pass:  db 'ADD r16, r/m16: PASS',0Dh,0Ah,'$'
test4_fail:  db 'ADD r16, r/m16: FAIL',0Dh,0Ah,'$'

test5_pass:  db 'ADD AL, d8: PASS',0Dh,0Ah,'$'
test5_fail:  db 'ADD AL, d8: FAIL',0Dh,0Ah,'$'

test6_pass:  db 'ADD AX, d16: PASS',0Dh,0Ah,'$'
test6_fail:  db 'ADD AX, d16: FAIL',0Dh,0Ah,'$'

msg_done:    db 0Dh,0Ah,'All tests complete.',0Dh,0Ah,'$'
