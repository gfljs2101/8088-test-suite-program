; 8088/8086 test suite for ADD and OR opcodes + PUSH/POP ES/CS
; NASM, org 0x100 -> flat .COM output
bits 16
org 0x100

start:
    ; Set DS = CS and set up a safe stack in this segment
    mov ax, cs
    mov ds, ax
    cli
    mov ss, ax
    mov sp, 0FF00h
    sti

    ; Run arithmetic tests (existing)
    call test_add_rm8_r8      ; ADD r/m8, r8
    call test_add_rm16_r16    ; ADD r/m16, r16
    call test_add_r8_rm8      ; ADD r8, r/m8
    call test_add_r16_rmem    ; ADD r16, r/m16
    call test_add_al_d8       ; ADD AL, d8
    call test_add_ax_d16      ; ADD AX, d16

    ; Run logical (OR) tests and segment register tests
    call test_or_rm8_r8
    call test_or_rm16_r16
    call test_or_r8_rm8
    call test_or_r16_rmem
    call test_or_al_imm8
    call test_or_ax_imm16

    call test_push_es
    call test_pop_es
    call test_push_cs
    ; POP CS is undefined/not supported - skipped

    ; Done
    mov dx, msg_done
    mov ah, 9
    int 21h

    mov ax, 4C00h
    int 21h

; ---------------------------------------------------------------------------
; Constants for flag masks and expected values
; Mask for OF, SF, ZF, AF, PF, CF  = bits 11,7,6,4,2,0  => 0x08D5
flag_mask_arith equ 0x08D5
; For logical ops AF is undefined on some CPUs - don't check AF (bit 4)
flag_mask_logic equ 0x08C5    ; flag_mask_arith & ~0x0010

; ---------------------------------------------------------------------------
; Existing ADD tests (unchanged except avoiding LEA) - Test 1..6
; Test 1: ADD r/m8, r8
test_add_rm8_r8:
    mov byte [mem_rm8], 0FFh
    mov al, 1
    add byte [mem_rm8], al           ; ADD r/m8, r8 (00 /r)
    ; check result
    mov al, [mem_rm8]
    cmp al, 0
    jne .t1_fail
    ; check flags
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_arith
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

; Test 2: ADD r/m16, r16
test_add_rm16_r16:
    mov word [mem_rm16], 0FFFFh
    mov bx, 1
    add word [mem_rm16], bx          ; ADD r/m16, r16 (01 /r)
    mov ax, [mem_rm16]
    cmp ax, 0
    jne .t2_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_arith
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

; Test 3: ADD r8, r/m8
test_add_r8_rm8:
    mov byte [mem_r8src], 0FFh
    mov al, 1
    add al, [mem_r8src]               ; ADD r8, r/m8 (02 /r)
    cmp al, 0
    jne .t3_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_arith
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

; Test 4: ADD r16, r/m16
test_add_r16_rmem:
    mov word [mem_r16src], 0FFFFh
    mov ax, 1
    add ax, [mem_r16src]               ; ADD r16, r/m16 (03 /r)
    cmp ax, 0
    jne .t4_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_arith
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

; Test 5: ADD AL, d8
test_add_al_d8:
    mov al, 7Fh
    add al, 01h                ; ADD AL, imm8 (04 ib)
    cmp al, 080h
    jne .t5_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_arith
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

; Test 6: ADD AX, d16
test_add_ax_d16:
    mov ax, 7FFFh
    add ax, 1                  ; ADD AX, imm16 (05 iw)
    cmp ax, 08000h
    jne .t6_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_arith
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
; OR tests (opcodes 08-0D)
; We'll avoid checking AF (undefined for logical ops) so use flag_mask_logic

; OR r/m8, r8  (08 /r)
test_or_rm8_r8:
    mov byte [or_rm8_a], 0Fh    ; 00001111b
    mov bl, 0F0h                ; 11110000b
    or byte [or_rm8_a], bl      ; OR r/m8, r8
    mov al, [or_rm8_a]
    cmp al, 0FFh
    jne .or1_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_logic
    cmp bx, 0x0084              ; SF=1 (0x0080) PF=1 (0x0004)
    jne .or1_fail
    mov dx, or1_pass
    jmp .or1_print
.or1_fail:
    mov dx, or1_fail
.or1_print:
    mov ah, 9
    int 21h
    ret

; OR r/m16, r16 (09 /r)
test_or_rm16_r16:
    mov word [or_rm16_a], 0FFh
    mov bx, 0FF00h
    or word [or_rm16_a], bx
    mov ax, [or_rm16_a]
    cmp ax, 0FFFFh
    jne .or2_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_logic
    cmp bx, 0x0084
    jne .or2_fail
    mov dx, or2_pass
    jmp .or2_print
.or2_fail:
    mov dx, or2_fail
.or2_print:
    mov ah, 9
    int 21h
    ret

; OR r8, r/m8 (0A /r)
test_or_r8_rm8:
    mov byte [or_rm8_b], 0Fh
    mov al, 0F0h
    or al, [or_rm8_b]
    cmp al, 0FFh
    jne .or3_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_logic
    cmp bx, 0x0084
    jne .or3_fail
    mov dx, or3_pass
    jmp .or3_print
.or3_fail:
    mov dx, or3_fail
.or3_print:
    mov ah, 9
    int 21h
    ret

; OR r16, r/m16 (0B /r)
test_or_r16_rmem:
    mov word [or_rm16_b], 0FFh
    mov ax, 0FF00h
    or ax, [or_rm16_b]
    cmp ax, 0FFFFh
    jne .or4_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_logic
    cmp bx, 0x0084
    jne .or4_fail
    mov dx, or4_pass
    jmp .or4_print
.or4_fail:
    mov dx, or4_fail
.or4_print:
    mov ah, 9
    int 21h
    ret

; OR AL, imm8 (0C ib)
test_or_al_imm8:
    mov al, 0Fh
    or al, 0F0h
    cmp al, 0FFh
    jne .or5_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_logic
    cmp bx, 0x0084
    jne .or5_fail
    mov dx, or5_pass
    jmp .or5_print
.or5_fail:
    mov dx, or5_fail
.or5_print:
    mov ah, 9
    int 21h
    ret

; OR AX, imm16 (0D iw)
test_or_ax_imm16:
    mov ax, 0FFh
    or ax, 0FF00h
    cmp ax, 0FFFFh
    jne .or6_fail
    pushf
    pop ax
    mov bx, ax
    and bx, flag_mask_logic
    cmp bx, 0x0084
    jne .or6_fail
    mov dx, or6_pass
    jmp .or6_print
.or6_fail:
    mov dx, or6_fail
.or6_print:
    mov ah, 9
    int 21h
    ret

; ---------------------------------------------------------------------------
; PUSH/POP ES and PUSH CS tests

; PUSH ES (0x06) - push ES then POP AX to verify value
test_push_es:
    mov ax, 0A5A0h
    mov es, ax
    push es
    pop ax
    cmp ax, 0A5A0h
    jne .pesh_fail
    mov dx, pesh_pass
    jmp .pesh_print
.pesh_fail:
    mov dx, pesh_fail
.pesh_print:
    mov ah, 9
    int 21h
    ret

; POP ES (0x07) - push a value then pop ES
test_pop_es:
    mov ax, 0BEEFh
    push ax
    pop es
    mov ax, es
    cmp ax, 0BEEFh
    jne .pes_fail
    mov dx, pes_pass
    jmp .pes_print
.pes_fail:
    mov dx, pes_fail
.pes_print:
    mov ah, 9
    int 21h
    ret

; PUSH CS (0x0E) - push CS then pop AX and compare
test_push_cs:
    push cs
    pop ax
    mov bx, cs
    cmp ax, bx
    jne .pcsh_fail
    mov dx, pcsh_pass
    jmp .pcsh_print
.pcsh_fail:
    mov dx, pcsh_fail
.pcsh_print:
    mov ah, 9
    int 21h
    ret

; ---------------------------------------------------------------------------
; Data area (strings and test memory)
mem_rm8:     db 0
mem_rm16:    dw 0
mem_r8src:   db 0
mem_r16src:  dw 0

or_rm8_a:    db 0
or_rm8_b:    db 0
or_rm16_a:   dw 0
or_rm16_b:   dw 0

; ADD test strings
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

; OR test strings
or1_pass:    db 'OR r/m8, r8: PASS',0Dh,0Ah,'$'
or1_fail:    db 'OR r/m8, r8: FAIL',0Dh,0Ah,'$'

or2_pass:    db 'OR r/m16, r16: PASS',0Dh,0Ah,'$'
or2_fail:    db 'OR r/m16, r16: FAIL',0Dh,0Ah,'$'

or3_pass:    db 'OR r8, r/m8: PASS',0Dh,0Ah,'$'
or3_fail:    db 'OR r8, r/m8: FAIL',0Dh,0Ah,'$'

or4_pass:    db 'OR r16, r/m16: PASS',0Dh,0Ah,'$'
or4_fail:    db 'OR r16, r/m16: FAIL',0Dh,0Ah,'$'

or5_pass:    db 'OR AL, imm8: PASS',0Dh,0Ah,'$'
or5_fail:    db 'OR AL, imm8: FAIL',0Dh,0Ah,'$'

or6_pass:    db 'OR AX, imm16: PASS',0Dh,0Ah,'$'
or6_fail:    db 'OR AX, imm16: FAIL',0Dh,0Ah,'$'

; PUSH/POP strings
pesh_pass:   db 'PUSH ES: PASS',0Dh,0Ah,'$'
pesh_fail:   db 'PUSH ES: FAIL',0Dh,0Ah,'$'

pes_pass:    db 'POP ES: PASS',0Dh,0Ah,'$'
pes_fail:    db 'POP ES: FAIL',0Dh,0Ah,'$'

pcsh_pass:   db 'PUSH CS: PASS',0Dh,0Ah,'$'
pcsh_fail:   db 'PUSH CS: FAIL',0Dh,0Ah,'$'

msg_done:    db 0Dh,0Ah,'All tests complete.',0Dh,0Ah,'$'
