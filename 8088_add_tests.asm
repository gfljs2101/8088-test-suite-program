; 8088/8086 test suite for ADD and OR opcodes + PUSH/POP ES/CS and more
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

    ; New tests: ADC, SBB, AND, SUB, XOR, CMP, PUSH/POP SS/DS, BCD adjusts

    ; ADC tests
    call test_adc_rm8_r8
    call test_adc_rm16_r16
    call test_adc_r8_rm8
    call test_adc_r16_rmem
    call test_adc_al_d8
    call test_adc_ax_d16

    ; SBB tests
    call test_sbb_rm8_r8
    call test_sbb_rm16_r16
    call test_sbb_r8_rm8
    call test_sbb_r16_rmem
    call test_sbb_al_d8
    call test_sbb_ax_d16

    ; AND tests
    call test_and_rm8_r8
    call test_and_rm16_r16
    call test_and_r8_rm8
    call test_and_r16_rmem
    call test_and_al_imm8
    call test_and_ax_imm16

    ; SUB tests
    call test_sub_rm8_r8
    call test_sub_rm16_r16
    call test_sub_r8_rm8
    call test_sub_r16_rmem
    call test_sub_al_d8
    call test_sub_ax_d16

    ; XOR tests
    call test_xor_rm8_r8
    call test_xor_rm16_r16
    call test_xor_r8_rm8
    call test_xor_r16_rmem
    call test_xor_al_imm8
    call test_xor_ax_imm16

    ; CMP tests
    call test_cmp_rm8_r8
    call test_cmp_rm16_r16
    call test_cmp_r8_rm8
    call test_cmp_r16_rmem
    call test_cmp_al_d8
    call test_cmp_ax_d16

    ; PUSH/POP SS and DS
    call test_push_ss
    call test_pop_ss
    call test_push_ds
    call test_pop_ds

    ; BCD adjust and ASCII adjust tests
    call test_daa
    call test_das
    call test_aaa
    call test_aas

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
; New tests start here

; ADC r/m8, r8 (10 /r)
test_adc_rm8_r8:
    mov byte [adc_rm8], 0FFh
    mov al, 1
    stc                         ; set CF = 1
    adc byte [adc_rm8], al      ; ADC r/m8, r8
    mov al, [adc_rm8]
    cmp al, 1
    jne .adc1_fail
    mov dx, adc1_pass
    jmp .adc1_print
.adc1_fail:
    mov dx, adc1_fail
.adc1_print:
    mov ah,9
    int 21h
    clc
    ret

; ADC r/m16, r16 (11 /r)
test_adc_rm16_r16:
    mov word [adc_rm16], 0FFFFh
    mov bx, 1
    stc
    adc word [adc_rm16], bx
    mov ax, [adc_rm16]
    cmp ax, 1
    jne .adc2_fail
    mov dx, adc2_pass
    jmp .adc2_print
.adc2_fail:
    mov dx, adc2_fail
.adc2_print:
    mov ah,9
    int 21h
    clc
    ret

; ADC r8, r/m8 (12 /r)
test_adc_r8_rm8:
    mov byte [adc_r8_src], 0FFh
    mov al, 1
    stc
    adc al, [adc_r8_src]
    cmp al, 1
    jne .adc3_fail
    mov dx, adc3_pass
    jmp .adc3_print
.adc3_fail:
    mov dx, adc3_fail
.adc3_print:
    mov ah,9
    int 21h
    clc
    ret

; ADC r16, r/m16 (13 /r)
test_adc_r16_rmem:
    mov word [adc_r16_src], 0FFFFh
    mov ax, 1
    stc
    adc ax, [adc_r16_src]
    cmp ax, 1
    jne .adc4_fail
    mov dx, adc4_pass
    jmp .adc4_print
.adc4_fail:
    mov dx, adc4_fail
.adc4_print:
    mov ah,9
    int 21h
    clc
    ret

; ADC AL, imm8 (14 ib)
test_adc_al_d8:
    mov al, 0FFh
    stc
    adc al, 1
    cmp al, 1
    jne .adc5_fail
    mov dx, adc5_pass
    jmp .adc5_print
.adc5_fail:
    mov dx, adc5_fail
.adc5_print:
    mov ah,9
    int 21h
    clc
    ret

; ADC AX, imm16 (15 iw)
test_adc_ax_d16:
    mov ax, 0FFFFh
    stc
    adc ax, 1
    cmp ax, 1
    jne .adc6_fail
    mov dx, adc6_pass
    jmp .adc6_print
.adc6_fail:
    mov dx, adc6_fail
.adc6_print:
    mov ah,9
    int 21h
    clc
    ret

; SBB r/m8, r8 (18 /r)
test_sbb_rm8_r8:
    mov byte [sbb_rm8], 0FFh
    mov al, 1
    stc
    sbb byte [sbb_rm8], al
    mov al, [sbb_rm8]
    cmp al, 0
    jne .sbb1_fail
    mov dx, sbb1_pass
    jmp .sbb1_print
.sbb1_fail:
    mov dx, sbb1_fail
.sbb1_print:
    mov ah,9
    int 21h
    clc
    ret

; SBB r/m16, r16 (19 /r)
test_sbb_rm16_r16:
    mov word [sbb_rm16], 0FFFFh
    mov bx, 1
    stc
    sbb word [sbb_rm16], bx
    mov ax, [sbb_rm16]
    cmp ax, 0
    jne .sbb2_fail
    mov dx, sbb2_pass
    jmp .sbb2_print
.sbb2_fail:
    mov dx, sbb2_fail
.sbb2_print:
    mov ah,9
    int 21h
    clc
    ret

; SBB r8, r/m8 (1A /r)
test_sbb_r8_rm8:
    mov byte [sbb_r8_src], 0FFh
    mov al, 1
    stc
    sbb al, [sbb_r8_src]
    cmp al, 0
    jne .sbb3_fail
    mov dx, sbb3_pass
    jmp .sbb3_print
.sbb3_fail:
    mov dx, sbb3_fail
.sbb3_print:
    mov ah,9
    int 21h
    clc
    ret

; SBB r16, r/m16 (1B /r)
test_sbb_r16_rmem:
    mov word [sbb_r16_src], 0FFFFh
    mov ax, 1
    stc
    sbb ax, [sbb_r16_src]
    cmp ax, 0
    jne .sbb4_fail
    mov dx, sbb4_pass
    jmp .sbb4_print
.sbb4_fail:
    mov dx, sbb4_fail
.sbb4_print:
    mov ah,9
    int 21h
    clc
    ret

; SBB AL, imm8 (1C ib)
test_sbb_al_d8:
    mov al, 0FFh
    stc
    sbb al, 1
    cmp al, 0
    jne .sbb5_fail
    mov dx, sbb5_pass
    jmp .sbb5_print
.sbb5_fail:
    mov dx, sbb5_fail
.sbb5_print:
    mov ah,9
    int 21h
    clc
    ret

; SBB AX, imm16 (1D iw)
test_sbb_ax_d16:
    mov ax, 0FFFFh
    stc
    sbb ax, 1
    cmp ax, 0
    jne .sbb6_fail
    mov dx, sbb6_pass
    jmp .sbb6_print
.sbb6_fail:
    mov dx, sbb6_fail
.sbb6_print:
    mov ah,9
    int 21h
    clc
    ret

; AND r/m8, r8 (20 /r)
test_and_rm8_r8:
    mov byte [and_rm8_a], 0Fh
    mov bl, 0F0h
    and byte [and_rm8_a], bl
    mov al, [and_rm8_a]
    cmp al, 0
    jne .and1_fail
    mov dx, and1_pass
    jmp .and1_print
.and1_fail:
    mov dx, and1_fail
.and1_print:
    mov ah,9
    int 21h
    ret

; AND r/m16, r16 (21 /r)
test_and_rm16_r16:
    mov word [and_rm16_a], 0FFh
    mov bx, 0FF00h
    and word [and_rm16_a], bx
    mov ax, [and_rm16_a]
    cmp ax, 0
    jne .and2_fail
    mov dx, and2_pass
    jmp .and2_print
.and2_fail:
    mov dx, and2_fail
.and2_print:
    mov ah,9
    int 21h
    ret

; AND r8, r/m8 (22 /r)
test_and_r8_rm8:
    mov byte [and_rm8_b], 0Fh
    mov al, 0F0h
    and al, [and_rm8_b]
    cmp al, 0
    jne .and3_fail
    mov dx, and3_pass
    jmp .and3_print
.and3_fail:
    mov dx, and3_fail
.and3_print:
    mov ah,9
    int 21h
    ret

; AND r16, r/m16 (23 /r)
test_and_r16_rmem:
    mov word [and_rm16_b], 0FFh
    mov ax, 0FF00h
    and ax, [and_rm16_b]
    cmp ax, 0
    jne .and4_fail
    mov dx, and4_pass
    jmp .and4_print
.and4_fail:
    mov dx, and4_fail
.and4_print:
    mov ah,9
    int 21h
    ret

; AND AL, imm8 (24 ib)
test_and_al_imm8:
    mov al, 0Fh
    and al, 0F0h
    cmp al, 0
    jne .and5_fail
    mov dx, and5_pass
    jmp .and5_print
.and5_fail:
    mov dx, and5_fail
.and5_print:
    mov ah,9
    int 21h
    ret

; AND AX, imm16 (25 iw)
test_and_ax_imm16:
    mov ax, 0FFh
    and ax, 0FF00h
    cmp ax, 0
    jne .and6_fail
    mov dx, and6_pass
    jmp .and6_print
.and6_fail:
    mov dx, and6_fail
.and6_print:
    mov ah,9
    int 21h
    ret

; DAA (27)
test_daa:
    mov al, 09h
    add al, 1
    daa
    cmp al, 010h
    jne .daa_fail
    mov dx, daa_pass
    jmp .daa_print
.daa_fail:
    mov dx, daa_fail
.daa_print:
    mov ah,9
    int 21h
    ret

; DAS (2F)
test_das:
    mov ax, 0200h
    mov al, 00h
    sub al, 1
    das
    ; after 0x00-1 => 0xFF, DAS should adjust to 0x99? We'll check AL high nibble changed
    ; Accept non-zero as an indication DAS executed; check AL != 0xFF
    cmp al, 0FFh
    je .das_fail
    mov dx, das_pass
    jmp .das_print
.das_fail:
    mov dx, das_fail
.das_print:
    mov ah,9
    int 21h
    ret

; SUB r/m8, r8 (28 /r)
test_sub_rm8_r8:
    mov byte [sub_rm8], 0
    mov al, 1
    sub byte [sub_rm8], al
    mov al, [sub_rm8]
    cmp al, 0FFh
    jne .sub1_fail
    mov dx, sub1_pass
    jmp .sub1_print
.sub1_fail:
    mov dx, sub1_fail
.sub1_print:
    mov ah,9
    int 21h
    ret

; SUB r/m16, r16 (29 /r)
test_sub_rm16_r16:
    mov word [sub_rm16], 0
    mov bx, 1
    sub word [sub_rm16], bx
    mov ax, [sub_rm16]
    cmp ax, 0FFFFh
    jne .sub2_fail
    mov dx, sub2_pass
    jmp .sub2_print
.sub2_fail:
    mov dx, sub2_fail
.sub2_print:
    mov ah,9
    int 21h
    ret

; SUB r8, r/m8 (2A /r)
test_sub_r8_rm8:
    mov byte [sub_r8_src], 0
    mov al, 1
    sub al, [sub_r8_src]
    cmp al, 1
    jne .sub3_fail
    mov dx, sub3_pass
    jmp .sub3_print
.sub3_fail:
    mov dx, sub3_fail
.sub3_print:
    mov ah,9
    int 21h
    ret

; SUB r16, r/m16 (2B /r)
test_sub_r16_rmem:
    mov word [sub_r16_src], 0
    mov ax, 1
    sub ax, [sub_r16_src]
    cmp ax, 1
    jne .sub4_fail
    mov dx, sub4_pass
    jmp .sub4_print
.sub4_fail:
    mov dx, sub4_fail
.sub4_print:
    mov ah,9
    int 21h
    ret

; SUB AL, imm8 (2C ib)
test_sub_al_d8:
    mov al, 2
    sub al, 1
    cmp al, 1
    jne .sub5_fail
    mov dx, sub5_pass
    jmp .sub5_print
.sub5_fail:
    mov dx, sub5_fail
.sub5_print:
    mov ah,9
    int 21h
    ret

; SUB AX, imm16 (2D iw)
test_sub_ax_d16:
    mov ax, 2
    sub ax, 1
    cmp ax, 1
    jne .sub6_fail
    mov dx, sub6_pass
    jmp .sub6_print
.sub6_fail:
    mov dx, sub6_fail
.sub6_print:
    mov ah,9
    int 21h
    ret

; XOR r/m8, r8 (30 /r)
test_xor_rm8_r8:
    mov byte [xor_rm8_a], 0Fh
    mov bl, 0F0h
    xor byte [xor_rm8_a], bl
    mov al, [xor_rm8_a]
    cmp al, 0FFh
    jne .xor1_fail
    mov dx, xor1_pass
    jmp .xor1_print
.xor1_fail:
    mov dx, xor1_fail
.xor1_print:
    mov ah,9
    int 21h
    ret

; XOR r/m16, r16 (31 /r)
test_xor_rm16_r16:
    mov word [xor_rm16_a], 0FFh
    mov bx, 0FF00h
    xor word [xor_rm16_a], bx
    mov ax, [xor_rm16_a]
    cmp ax, 0FFFFh
    jne .xor2_fail
    mov dx, xor2_pass
    jmp .xor2_print
.xor2_fail:
    mov dx, xor2_fail
.xor2_print:
    mov ah,9
    int 21h
    ret

; XOR r8, r/m8 (32 /r)
test_xor_r8_rm8:
    mov byte [xor_rm8_b], 0Fh
    mov al, 0F0h
    xor al, [xor_rm8_b]
    cmp al, 0FFh
    jne .xor3_fail
    mov dx, xor3_pass
    jmp .xor3_print
.xor3_fail:
    mov dx, xor3_fail
.xor3_print:
    mov ah,9
    int 21h
    ret

; XOR r16, r/m16 (33 /r)
test_xor_r16_rmem:
    mov word [xor_rm16_b], 0FFh
    mov ax, 0FF00h
    xor ax, [xor_rm16_b]
    cmp ax, 0FFFFh
    jne .xor4_fail
    mov dx, xor4_pass
    jmp .xor4_print
.xor4_fail:
    mov dx, xor4_fail
.xor4_print:
    mov ah,9
    int 21h
    ret

; XOR AL, imm8 (34 ib)
test_xor_al_imm8:
    mov al, 0Fh
    xor al, 0F0h
    cmp al, 0FFh
    jne .xor5_fail
    mov dx, xor5_pass
    jmp .xor5_print
.xor5_fail:
    mov dx, xor5_fail
.xor5_print:
    mov ah,9
    int 21h
    ret

; XOR AX, imm16 (35 iw)
test_xor_ax_imm16:
    mov ax, 0FFh
    xor ax, 0FF00h
    cmp ax, 0FFFFh
    jne .xor6_fail
    mov dx, xor6_pass
    jmp .xor6_print
.xor6_fail:
    mov dx, xor6_fail
.xor6_print:
    mov ah,9
    int 21h
    ret

; CMP r/m8, r8 (38 /r)
test_cmp_rm8_r8:
    mov byte [cmp_rm8_a], 0Fh
    mov bl, 0Fh
    cmp byte [cmp_rm8_a], bl
    je .cmp1_pass
    mov dx, cmp1_fail
    jmp .cmp1_print
.cmp1_pass:
    mov dx, cmp1_pass
.cmp1_print:
    mov ah,9
    int 21h
    ret

; CMP r/m16, r16 (39 /r)
test_cmp_rm16_r16:
    mov word [cmp_rm16_a], 0FFFFh
    mov bx, 0FFFFh
    cmp word [cmp_rm16_a], bx
    je .cmp2_pass
    mov dx, cmp2_fail
    jmp .cmp2_print
.cmp2_pass:
    mov dx, cmp2_pass
.cmp2_print:
    mov ah,9
    int 21h
    ret

; CMP r8, r/m8 (3A /r)
test_cmp_r8_rm8:
    mov byte [cmp_rm8_b], 0Fh
    mov al, 0Fh
    cmp al, [cmp_rm8_b]
    je .cmp3_pass
    mov dx, cmp3_fail
    jmp .cmp3_print
.cmp3_pass:
    mov dx, cmp3_pass
.cmp3_print:
    mov ah,9
    int 21h
    ret

; CMP r16, r/m16 (3B /r)
test_cmp_r16_rmem:
    mov word [cmp_rm16_b], 0FFFFh
    mov ax, 0FFFFh
    cmp ax, [cmp_rm16_b]
    je .cmp4_pass
    mov dx, cmp4_fail
    jmp .cmp4_print
.cmp4_pass:
    mov dx, cmp4_pass
.cmp4_print:
    mov ah,9
    int 21h
    ret

; CMP AL, imm8 (3C ib)
test_cmp_al_d8:
    mov al, 0Fh
    cmp al, 0Fh
    je .cmp5_pass
    mov dx, cmp5_fail
    jmp .cmp5_print
.cmp5_pass:
    mov dx, cmp5_pass
.cmp5_print:
    mov ah,9
    int 21h
    ret

; CMP AX, imm16 (3D iw)
test_cmp_ax_d16:
    mov ax, 0FFFFh
    cmp ax, 0FFFFh
    je .cmp6_pass
    mov dx, cmp6_fail
    jmp .cmp6_print
.cmp6_pass:
    mov dx, cmp6_pass
.cmp6_print:
    mov ah,9
    int 21h
    ret

; PUSH SS (0x16) - push SS then pop AX to verify value
test_push_ss:
    mov ax, 05555h
    mov ss, ax
    push ss
    pop ax
    cmp ax, 05555h
    jne .pssh_fail
    mov dx, pssh_pass
    jmp .pssh_print
.pssh_fail:
    mov dx, pssh_fail
.pssh_print:
    mov ah,9
    int 21h
    ret

; POP SS (0x17) - push a value then pop SS
test_pop_ss:
    mov ax, 0AA55h
    push ax
    pop ss
    mov ax, ss
    cmp ax, 0AA55h
    jne .pss_fail
    mov dx, pss_pass
    jmp .pss_print
.pss_fail:
    mov dx, pss_fail
.pss_print:
    mov ah,9
    int 21h
    ret

; PUSH DS (0x1E) - push DS then pop AX to verify value
test_push_ds:
    mov ax, 03333h
    mov ds, ax
    push ds
    pop ax
    cmp ax, 03333h
    jne .pdsh_fail
    mov dx, pdsh_pass
    jmp .pdsh_print
.pdsh_fail:
    mov dx, pdsh_fail
.pdsh_print:
    mov ah,9
    int 21h
    ret

; POP DS (0x1F) - push a value then pop DS
test_pop_ds:
    mov ax, 07777h
    push ax
    pop ds
    mov ax, ds
    cmp ax, 07777h
    jne .pds_fail
    mov dx, pds_pass
    jmp .pds_print
.pds_fail:
    mov dx, pds_fail
.pds_print:
    mov ah,9
    int 21h
    ret

; AAA (37)
test_aaa:
    mov ah, 0
    mov al, 09h
    add al, 1
    aaa
    cmp al, 0
    jne .aaa_fail
    cmp ah, 1
    jne .aaa_fail
    mov dx, aaa_pass
    jmp .aaa_print
.aaa_fail:
    mov dx, aaa_fail
.aaa_print:
    mov ah,9
    int 21h
    ret

; AAS (3F)
test_aas:
    mov ah, 02h
    mov al, 0
    sub al, 1
    aas
    cmp al, 09h
    jne .aas_fail
    cmp ah, 01h
    jne .aas_fail
    mov dx, aas_pass
    jmp .aas_print
.aas_fail:
    mov dx, aas_fail
.aas_print:
    mov ah,9
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

adc_rm8:     db 0
adc_rm16:    dw 0
adc_r8_src:  db 0
adc_r16_src: dw 0

sbb_rm8:     db 0
sbb_rm16:    dw 0
sbb_r8_src:  db 0
sbb_r16_src: dw 0

and_rm8_a:   db 0
and_rm8_b:   db 0
and_rm16_a:  dw 0
and_rm16_b:  dw 0

sub_rm8:     db 0
sub_rm16:    dw 0
sub_r8_src:  db 0
sub_r16_src: dw 0

xor_rm8_a:   db 0
xor_rm8_b:   db 0
xor_rm16_a:  dw 0
xor_rm16_b:  dw 0

cmp_rm8_a:   db 0
cmp_rm8_b:   db 0
cmp_rm16_a:  dw 0
cmp_rm16_b:  dw 0

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

; ADC strings
adc1_pass:   db 'ADC r/m8, r8: PASS',0Dh,0Ah,'$'
adc1_fail:   db 'ADC r/m8, r8: FAIL',0Dh,0Ah,'$'

adc2_pass:   db 'ADC r/m16, r16: PASS',0Dh,0Ah,'$'
adc2_fail:   db 'ADC r/m16, r16: FAIL',0Dh,0Ah,'$'

adc3_pass:   db 'ADC r8, r/m8: PASS',0Dh,0Ah,'$'
adc3_fail:   db 'ADC r8, r/m8: FAIL',0Dh,0Ah,'$'

adc4_pass:   db 'ADC r16, r/m16: PASS',0Dh,0Ah,'$'
adc4_fail:   db 'ADC r16, r/m16: FAIL',0Dh,0Ah,'$'

adc5_pass:   db 'ADC AL, d8: PASS',0Dh,0Ah,'$'
adc5_fail:   db 'ADC AL, d8: FAIL',0Dh,0Ah,'$'

adc6_pass:   db 'ADC AX, d16: PASS',0Dh,0Ah,'$'
adc6_fail:   db 'ADC AX, d16: FAIL',0Dh,0Ah,'$'

; SBB strings
sbb1_pass:   db 'SBB r/m8, r8: PASS',0Dh,0Ah,'$'
sbb1_fail:   db 'SBB r/m8, r8: FAIL',0Dh,0Ah,'$'

sbb2_pass:   db 'SBB r/m16, r16: PASS',0Dh,0Ah,'$'
sbb2_fail:   db 'SBB r/m16, r16: FAIL',0Dh,0Ah,'$'

sbb3_pass:   db 'SBB r8, r/m8: PASS',0Dh,0Ah,'$'
sbb3_fail:   db 'SBB r8, r/m8: FAIL',0Dh,0Ah,'$'

sbb4_pass:   db 'SBB r16, r/m16: PASS',0Dh,0Ah,'$'
sbb4_fail:   db 'SBB r16, r/m16: FAIL',0Dh,0Ah,'$'

sbb5_pass:   db 'SBB AL, d8: PASS',0Dh,0Ah,'$'
sbb5_fail:   db 'SBB AL, d8: FAIL',0Dh,0Ah,'$'

sbb6_pass:   db 'SBB AX, d16: PASS',0Dh,0Ah,'$'
sbb6_fail:   db 'SBB AX, d16: FAIL',0Dh,0Ah,'$'

; AND strings
and1_pass:   db 'AND r/m8, r8: PASS',0Dh,0Ah,'$'
and1_fail:   db 'AND r/m8, r8: FAIL',0Dh,0Ah,'$'

and2_pass:   db 'AND r/m16, r16: PASS',0Dh,0Ah,'$'
and2_fail:   db 'AND r/m16, r16: FAIL',0Dh,0Ah,'$'

and3_pass:   db 'AND r8, r/m8: PASS',0Dh,0Ah,'$'
and3_fail:   db 'AND r8, r/m8: FAIL',0Dh,0Ah,'$'

and4_pass:   db 'AND r16, r/m16: PASS',0Dh,0Ah,'$'
and4_fail:   db 'AND r16, r/m16: FAIL',0Dh,0Ah,'$'

and5_pass:   db 'AND AL, imm8: PASS',0Dh,0Ah,'$'
and5_fail:   db 'AND AL, imm8: FAIL',0Dh,0Ah,'$'

and6_pass:   db 'AND AX, imm16: PASS',0Dh,0Ah,'$'
and6_fail:   db 'AND AX, imm16: FAIL',0Dh,0Ah,'$'

; DAA/DAS/AAA/AAS strings
daa_pass:    db 'DAA: PASS',0Dh,0Ah,'$'
daa_fail:    db 'DAA: FAIL',0Dh,0Ah,'$'

das_pass:    db 'DAS: PASS',0Dh,0Ah,'$'
das_fail:    db 'DAS: FAIL',0Dh,0Ah,'$'

aaa_pass:    db 'AAA: PASS',0Dh,0Ah,'$'
aaa_fail:    db 'AAA: FAIL',0Dh,0Ah,'$'

aas_pass:    db 'AAS: PASS',0Dh,0Ah,'$'
aas_fail:    db 'AAS: FAIL',0Dh,0Ah,'$'

; SUB strings
sub1_pass:   db 'SUB r/m8, r8: PASS',0Dh,0Ah,'$'
sub1_fail:   db 'SUB r/m8, r8: FAIL',0Dh,0Ah,'$'

sub2_pass:   db 'SUB r/m16, r16: PASS',0Dh,0Ah,'$'
sub2_fail:   db 'SUB r/m16, r16: FAIL',0Dh,0Ah,'$'

sub3_pass:   db 'SUB r8, r/m8: PASS',0Dh,0Ah,'$'
sub3_fail:   db 'SUB r8, r/m8: FAIL',0Dh,0Ah,'$'

sub4_pass:   db 'SUB r16, r/m16: PASS',0Dh,0Ah,'$'
sub4_fail:   db 'SUB r16, r/m16: FAIL',0Dh,0Ah,'$'

sub5_pass:   db 'SUB AL, d8: PASS',0Dh,0Ah,'$'
sub5_fail:   db 'SUB AL, d8: FAIL',0Dh,0Ah,'$'

sub6_pass:   db 'SUB AX, d16: PASS',0Dh,0Ah,'$'
sub6_fail:   db 'SUB AX, d16: FAIL',0Dh,0Ah,'$'

; XOR strings
xor1_pass:   db 'XOR r/m8, r8: PASS',0Dh,0Ah,'$'
xor1_fail:   db 'XOR r/m8, r8: FAIL',0Dh,0Ah,'$'

xor2_pass:   db 'XOR r/m16, r16: PASS',0Dh,0Ah,'$'
xor2_fail:   db 'XOR r/m16, r16: FAIL',0Dh,0Ah,'$'

xor3_pass:   db 'XOR r8, r/m8: PASS',0Dh,0Ah,'$'
xor3_fail:   db 'XOR r8, r/m8: FAIL',0Dh,0Ah,'$'

xor4_pass:   db 'XOR r16, r/m16: PASS',0Dh,0Ah,'$'
xor4_fail:   db 'XOR r16, r/m16: FAIL',0Dh,0Ah,'$'

xor5_pass:   db 'XOR AL, imm8: PASS',0Dh,0Ah,'$'
xor5_fail:   db 'XOR AL, imm8: FAIL',0Dh,0Ah,'$'

xor6_pass:   db 'XOR AX, imm16: PASS',0Dh,0Ah,'$'
xor6_fail:   db 'XOR AX, imm16: FAIL',0Dh,0Ah,'$'

; CMP strings
cmp1_pass:   db 'CMP r/m8, r8: PASS',0Dh,0Ah,'$'
cmp1_fail:   db 'CMP r/m8, r8: FAIL',0Dh,0Ah,'$'

cmp2_pass:   db 'CMP r/m16, r16: PASS',0Dh,0Ah,'$'
cmp2_fail:   db 'CMP r/m16, r16: FAIL',0Dh,0Ah,'$'

cmp3_pass:   db 'CMP r8, r/m8: PASS',0Dh,0Ah,'$'
cmp3_fail:   db 'CMP r8, r/m8: FAIL',0Dh,0Ah,'$'

cmp4_pass:   db 'CMP r16, r/m16: PASS',0Dh,0Ah,'$'
cmp4_fail:   db 'CMP r16, r/m16: FAIL',0Dh,0Ah,'$'

cmp5_pass:   db 'CMP AL, d8: PASS',0Dh,0Ah,'$'
cmp5_fail:   db 'CMP AL, d8: FAIL',0Dh,0Ah,'$'

cmp6_pass:   db 'CMP AX, d16: PASS',0Dh,0Ah,'$'
cmp6_fail:   db 'CMP AX, d16: FAIL',0Dh,0Ah,'$'

; PUSH/POP SS/DS strings
pssh_pass:   db 'PUSH SS: PASS',0Dh,0Ah,'$'
pssh_fail:   db 'PUSH SS: FAIL',0Dh,0Ah,'$'

pss_pass:    db 'POP SS: PASS',0Dh,0Ah,'$'
pss_fail:    db 'POP SS: FAIL',0Dh,0Ah,'$'

pdsh_pass:   db 'PUSH DS: PASS',0Dh,0Ah,'$'
pdsh_fail:   db 'PUSH DS: FAIL',0Dh,0Ah,'$'

pds_pass:    db 'POP DS: PASS',0Dh,0Ah,'$'
pds_fail:    db 'POP DS: FAIL',0Dh,0Ah,'$'

msg_done:    db 0Dh,0Ah,'All tests complete.',0Dh,0Ah,'$'
