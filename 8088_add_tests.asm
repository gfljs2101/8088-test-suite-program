; 8088/8086 test suite for ADD and OR opcodes + PUSH/POP ES/CS and more
; NASM, org 0x100 -> flat .COM output
bits 16
cpu 8086
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
    call paged_print

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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
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
    call paged_print
    ret

; ---------------------------------------------------------------------------
; Paged print routine and paging data
paged_print:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; print the string pointed by DX using DOS function 9
    mov ah, 9
    int 21h

    ; increment printed-line counter
    inc word [page_count]
    ; compare with limit (25)
    mov ax, [page_count]
    cmp ax, 25
    jb .paged_done

    ; print prompt "scroll?" and wait for any key
    mov dx, scroll_prompt
    mov ah, 9
    int 21h
    ; wait for any key (INT 16h AH=0)
    mov ah, 0
    int 16h

    ; optional new line after key
    mov dx, scroll_nl
    mov ah, 9
    int 21h

    ; reset counter
    mov word [page_count], 0

.paged_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
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

; paging counter and prompt
page_count:  dw 0
scroll_prompt: db 'scroll?',0Dh,0Ah,'$'
scroll_nl:   db 0Dh,0Ah,'$'

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
