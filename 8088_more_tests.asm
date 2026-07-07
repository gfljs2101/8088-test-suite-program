; Additional 8088/8086 opcode tests: INC/DEC registers, PUSH/POP registers, conditional jumps (rel8)
; NASM, org 0x100 -> flat .COM output
bits 16
cpu 8086
org 0x100

; This file provides supplemental tests. Call the tests from your main test driver
; (e.g., from 8088_add_tests.asm start: section) by adding calls like:
;   call more_test_inc_dec
;   call more_test_push_pop_regs
;   call more_test_jcc_rel8
;
; The tests use DOS function 9 (DX -> string) to print PASS/FAIL messages and
; return to the caller with RET.

; ---------------------------------------------------------------------------
; INC / DEC register tests
more_test_inc_dec:
    call test_inc_ax
    call test_inc_cx
    call test_inc_dx
    call test_inc_bx
    call test_inc_sp
    call test_inc_bp
    call test_inc_si
    call test_inc_di

    call test_dec_ax
    call test_dec_cx
    call test_dec_dx
    call test_dec_bx
    call test_dec_sp
    call test_dec_bp
    call test_dec_si
    call test_dec_di

    ret

; Generic helper macro isn't available here; write tests verbosely

; INC AX
test_inc_ax:
    mov ax, 0FFFFh
    inc ax
    cmp ax, 0
    jne .incax_fail
    mov dx, msg_inc_ax_pass
    jmp .incax_print
.incax_fail:
    mov dx, msg_inc_ax_fail
.incax_print:
    call more_paged_print
    ret

; INC CX
test_inc_cx:
    mov cx, 0FFFFh
    inc cx
    cmp cx, 0
    jne .inccx_fail
    mov dx, msg_inc_cx_pass
    jmp .inccx_print
.inccx_fail:
    mov dx, msg_inc_cx_fail
.inccx_print:
    call more_paged_print
    ret

; INC DX
test_inc_dx:
    mov dx, 0FFFFh
    inc dx
    cmp dx, 0
    jne .incdx_fail
    mov dx, msg_inc_dx_pass
    jmp .incdx_print
.incdx_fail:
    mov dx, msg_inc_dx_fail
.incdx_print:
    call more_paged_print
    ret

; INC BX
test_inc_bx:
    mov bx, 0FFFFh
    inc bx
    cmp bx, 0
    jne .incbx_fail
    mov dx, msg_inc_bx_pass
    jmp .incbx_print
.incbx_fail:
    mov dx, msg_inc_bx_fail
.incbx_print:
    call more_paged_print
    ret

; INC SP
test_inc_sp:
    mov sp, 0FFFEh
    inc sp
    cmp sp, 0FFFFh
    jne .incsp_fail
    mov dx, msg_inc_sp_pass
    jmp .incsp_print
.incsp_fail:
    mov dx, msg_inc_sp_fail
.incsp_print:
    call more_paged_print
    ret

; INC BP
test_inc_bp:
    mov bp, 0FFFFh
    inc bp
    cmp bp, 0
    jne .incbp_fail
    mov dx, msg_inc_bp_pass
    jmp .incbp_print
.incbp_fail:
    mov dx, msg_inc_bp_fail
.incbp_print:
    call more_paged_print
    ret

; INC SI
test_inc_si:
    mov si, 0FFFFh
    inc si
    cmp si, 0
    jne .incsi_fail
    mov dx, msg_inc_si_pass
    jmp .incsi_print
.incsi_fail:
    mov dx, msg_inc_si_fail
.incsi_print:
    call more_paged_print
    ret

; INC DI
test_inc_di:
    mov di, 0FFFFh
    inc di
    cmp di, 0
    jne .incdi_fail
    mov dx, msg_inc_di_pass
    jmp .incdi_print
.incdi_fail:
    mov dx, msg_inc_di_fail
.incdi_print:
    call more_paged_print
    ret

; DEC AX
test_dec_ax:
    mov ax, 0
    dec ax
    cmp ax, 0FFFFh
    jne .decax_fail
    mov dx, msg_dec_ax_pass
    jmp .decax_print
.decax_fail:
    mov dx, msg_dec_ax_fail
.decax_print:
    call more_paged_print
    ret

; DEC CX
test_dec_cx:
    mov cx, 0
    dec cx
    cmp cx, 0FFFFh
    jne .deccx_fail
    mov dx, msg_dec_cx_pass
    jmp .deccx_print
.deccx_fail:
    mov dx, msg_dec_cx_fail
.deccx_print:
    call more_paged_print
    ret

; DEC DX
test_dec_dx:
    mov dx, 0
    dec dx
    cmp dx, 0FFFFh
    jne .decdx_fail
    mov dx, msg_dec_dx_pass
    jmp .decdx_print
.decdx_fail:
    mov dx, msg_dec_dx_fail
.decdx_print:
    call more_paged_print
    ret

; DEC BX
test_dec_bx:
    mov bx, 0
    dec bx
    cmp bx, 0FFFFh
    jne .decbx_fail
    mov dx, msg_dec_bx_pass
    jmp .decbx_print
.decbx_fail:
    mov dx, msg_dec_bx_fail
.decbx_print:
    call more_paged_print
    ret

; DEC SP
test_dec_sp:
    mov sp, 0
    dec sp
    cmp sp, 0FFFFh
    jne .decsp_fail
    mov dx, msg_dec_sp_pass
    jmp .decsp_print
.decsp_fail:
    mov dx, msg_dec_sp_fail
.decsp_print:
    call more_paged_print
    ret

; DEC BP
test_dec_bp:
    mov bp, 0
    dec bp
    cmp bp, 0FFFFh
    jne .decbp_fail
    mov dx, msg_dec_bp_pass
    jmp .decbp_print
.decbp_fail:
    mov dx, msg_dec_bp_fail
.decbp_print:
    call more_paged_print
    ret

; DEC SI
test_dec_si:
    mov si, 0
    dec si
    cmp si, 0FFFFh
    jne .decsi_fail
    mov dx, msg_dec_si_pass
    jmp .decsi_print
.decsi_fail:
    mov dx, msg_dec_si_fail
.decsi_print:
    call more_paged_print
    ret

; DEC DI
test_dec_di:
    mov di, 0
    dec di
    cmp di, 0FFFFh
    jne .decdi_fail
    mov dx, msg_dec_di_pass
    jmp .decdi_print
.decdi_fail:
    mov dx, msg_dec_di_fail
.decdi_print:
    call more_paged_print
    ret

; ---------------------------------------------------------------------------
; PUSH/POP register tests
more_test_push_pop_regs:
    call test_push_pop_ax
    call test_push_pop_cx
    call test_push_pop_dx
    call test_push_pop_bx
    call test_push_pop_sp
    call test_push_pop_bp
    call test_push_pop_si
    call test_push_pop_di
    ret

test_push_pop_ax:
    mov ax, 0A5Ah
    push ax
    xor ax, ax
    pop ax
    cmp ax, 0A5Ah
    jne .ppax_fail
    mov dx, msg_pp_ax_pass
    jmp .ppax_print
.ppax_fail:
    mov dx, msg_pp_ax_fail
.ppax_print:
    call more_paged_print
    ret

test_push_pop_cx:
    mov cx, 0C3CCh
    push cx
    xor cx, cx
    pop cx
    cmp cx, 0C3CCh
    jne .ppcx_fail
    mov dx, msg_pp_cx_pass
    jmp .ppcx_print
.ppcx_fail:
    mov dx, msg_pp_cx_fail
.ppcx_print:
    call more_paged_print
    ret

test_push_pop_dx:
    mov dx, 0D3D3h
    push dx
    xor dx, dx
    pop dx
    cmp dx, 0D3D3h
    jne .ppdx_fail
    mov dx, msg_pp_dx_pass
    jmp .ppdx_print
.ppdx_fail:
    mov dx, msg_pp_dx_fail
.ppdx_print:
    call more_paged_print
    ret

test_push_pop_bx:
    mov bx, 0B3B3h
    push bx
    xor bx, bx
    pop bx
    cmp bx, 0B3B3h
    jne .ppbx_fail
    mov dx, msg_pp_bx_pass
    jmp .ppbx_print
.ppbx_fail:
    mov dx, msg_pp_bx_fail
.ppbx_print:
    call more_paged_print
    ret

test_push_pop_sp:
    ; pushing SP is allowed; but popping SP will restore original SP
    mov ax, sp
    push sp
    ; modify sp (add) then pop back to verify stack behavior
    add sp, 2
    pop bx        ; retrieve saved SP into BX
    cmp bx, ax
    jne .ppsp_fail
    mov dx, msg_pp_sp_pass
    jmp .ppsp_print
.ppsp_fail:
    mov dx, msg_pp_sp_fail
.ppsp_print:
    call more_paged_print
    ret

test_push_pop_bp:
    mov bp, 0BEEFh
    push bp
    xor bp, bp
    pop bp
    cmp bp, 0BEEFh
    jne .ppbp_fail
    mov dx, msg_pp_bp_pass
    jmp .ppbp_print
.ppbp_fail:
    mov dx, msg_pp_bp_fail
.ppbp_print:
    call more_paged_print
    ret

test_push_pop_si:
    mov si, 0S1Ih ; purposely invalid hex label will be adjusted by assembler if needed
    ; use a concrete value instead
    mov si, 0AA55h
    push si
    xor si, si
    pop si
    cmp si, 0AA55h
    jne .ppsi_fail
    mov dx, msg_pp_si_pass
    jmp .ppsi_print
.ppsi_fail:
    mov dx, msg_pp_si_fail
.ppsi_print:
    call more_paged_print
    ret

test_push_pop_di:
    mov di, 0DD44h
    push di
    xor di, di
    pop di
    cmp di, 0DD44h
    jne .ppdi_fail
    mov dx, msg_pp_di_pass
    jmp .ppdi_print
.ppdi_fail:
    mov dx, msg_pp_di_fail
.ppdi_print:
    call more_paged_print
    ret

; ---------------------------------------------------------------------------
; Conditional jumps (rel8) tests
; We'll set flags and test the conditional jump targets
more_test_jcc_rel8:
    call test_jo
    call test_jno
    call test_jb
    call test_jnb
    call test_je
    call test_jne
    call test_jbe
    call test_ja
    call test_js
    call test_jns
    call test_jp
    call test_jnp
    call test_jl
    call test_jnl
    call test_jle
    call test_jg
    ret

; JO - jump if overflow
test_jo:
    ; cause overflow: add signed max + 1
    mov al, 7Fh
    add al, 1
    jo .jo_pass
    mov dx, msg_jo_fail
    jmp .jo_print
.jo_pass:
    mov dx, msg_jo_pass
.jo_print:
    call more_paged_print
    ret

; JNO - jump if not overflow
test_jno:
    mov al, 1
    add al, 1
    jno .jno_pass
    mov dx, msg_jno_fail
    jmp .jno_print
.jno_pass:
    mov dx, msg_jno_pass
.jno_print:
    call more_paged_print
    ret

; JB / JNAE - jump if below (CF=1)
test_jb:
    mov al, 0
    sub al, 1   ; sets CF
    jb .jb_pass
    mov dx, msg_jb_fail
    jmp .jb_print
.jb_pass:
    mov dx, msg_jb_pass
.jb_print:
    call more_paged_print
    ret

; JNB / JAE - jump if not below (CF=0)
test_jnb:
    mov al, 2
    sub al, 1   ; CF=0
    jnb .jnb_pass
    mov dx, msg_jnb_fail
    jmp .jnb_print
.jnb_pass:
    mov dx, msg_jnb_pass
.jnb_print:
    call more_paged_print
    ret

; JE / JZ - zero flag
test_je:
    mov ax, 1
    sub ax, 1
    je .je_pass
    mov dx, msg_je_fail
    jmp .je_print
.je_pass:
    mov dx, msg_je_pass
.je_print:
    call more_paged_print
    ret

; JNE / JNZ
test_jne:
    mov ax, 2
    sub ax, 1
    jne .jne_pass
    mov dx, msg_jne_fail
    jmp .jne_print
.jne_pass:
    mov dx, msg_jne_pass
.jne_print:
    call more_paged_print
    ret

; JBE / JNA - CF=1 or ZF=1
test_jbe:
    mov al, 1
    sub al, 1   ; ZF=1
    jbe .jbe_pass
    mov dx, msg_jbe_fail
    jmp .jbe_print
.jbe_pass:
    mov dx, msg_jbe_pass
.jbe_print:
    call more_paged_print
    ret

; JA / JNBE - not below or equal
test_ja:
    mov al, 3
    sub al, 1   ; CF=0,ZF=0
    ja .ja_pass
    mov dx, msg_ja_fail
    jmp .ja_print
.ja_pass:
    mov dx, msg_ja_pass
.ja_print:
    call more_paged_print
    ret

; JS - sign flag
test_js:
    mov al, 80h
    ; AL is negative in signed interpretation; subtract 1 to keep SF
    sub al, 0
    js .js_pass
    mov dx, msg_js_fail
    jmp .js_print
.js_pass:
    mov dx, msg_js_pass
.js_print:
    call more_paged_print
    ret

; JNS - not sign
test_jns:
    mov al, 1
    jns .jns_pass
    mov dx, msg_jns_fail
    jmp .jns_print
.jns_pass:
    mov dx, msg_jns_pass
.jns_print:
    call more_paged_print
    ret

; JP / JPE - parity even
test_jp:
    ; set even parity: 0 has even parity
    mov al, 0
    test al, al
    jp .jp_pass
    mov dx, msg_jp_fail
    jmp .jp_print
.jp_pass:
    mov dx, msg_jp_pass
.jp_print:
    call more_paged_print
    ret

; JNP / JPO - parity odd
test_jnp:
    mov al, 1 ; 1 has odd parity
    test al, al
    jnp .jnp_pass
    mov dx, msg_jnp_fail
    jmp .jnp_print
.jnp_pass:
    mov dx, msg_jnp_pass
.jnp_print:
    call more_paged_print
    ret

; JL / JNGE - less (signed)
test_jl:
    mov al, 80h
    mov bl, 1
    sub al, bl   ; negative
    jl .jl_pass
    mov dx, msg_jl_fail
    jmp .jl_print
.jl_pass:
    mov dx, msg_jl_pass
.jl_print:
    call more_paged_print
    ret

; JNL / JGE - not less (signed)
test_jnl:
    mov al, 2
    sub al, 1
    jnl .jnl_pass
    mov dx, msg_jnl_fail
    jmp .jnl_print
.jnl_pass:
    mov dx, msg_jnl_pass
.jnl_print:
    call more_paged_print
    ret

; JLE / JNG - less or equal (signed)
test_jle:
    mov al, 1
    sub al, 1
    jle .jle_pass
    mov dx, msg_jle_fail
    jmp .jle_print
.jle_pass:
    mov dx, msg_jle_pass
.jle_print:
    call more_paged_print
    ret

; JG / JNLE - greater (signed)
test_jg:
    mov al, 3
    sub al, 1
    jg .jg_pass
    mov dx, msg_jg_fail
    jmp .jg_print
.jg_pass:
    mov dx, msg_jg_pass
.jg_print:
    call more_paged_print
    ret

; ---------------------------------------------------------------------------
; Minimal paged_print compatible routine for these supplemental tests
; This is independent from the main file's paged_print; it simply prints DX string
more_paged_print:
    push ax
    push bx
    push cx
    push dx
    mov ah, 9
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ---------------------------------------------------------------------------
; Messages and data
section .data
msg_inc_ax_pass    db 'INC AX: PASS',0Dh,0Ah,'$'
msg_inc_ax_fail    db 'INC AX: FAIL',0Dh,0Ah,'$'
msg_inc_cx_pass    db 'INC CX: PASS',0Dh,0Ah,'$'
msg_inc_cx_fail    db 'INC CX: FAIL',0Dh,0Ah,'$'
msg_inc_dx_pass    db 'INC DX: PASS',0Dh,0Ah,'$'
msg_inc_dx_fail    db 'INC DX: FAIL',0Dh,0Ah,'$'
msg_inc_bx_pass    db 'INC BX: PASS',0Dh,0Ah,'$'
msg_inc_bx_fail    db 'INC BX: FAIL',0Dh,0Ah,'$'
msg_inc_sp_pass    db 'INC SP: PASS',0Dh,0Ah,'$'
msg_inc_sp_fail    db 'INC SP: FAIL',0Dh,0Ah,'$'
msg_inc_bp_pass    db 'INC BP: PASS',0Dh,0Ah,'$'
msg_inc_bp_fail    db 'INC BP: FAIL',0Dh,0Ah,'$'
msg_inc_si_pass    db 'INC SI: PASS',0Dh,0Ah,'$'
msg_inc_si_fail    db 'INC SI: FAIL',0Dh,0Ah,'$'
msg_inc_di_pass    db 'INC DI: PASS',0Dh,0Ah,'$'
msg_inc_di_fail    db 'INC DI: FAIL',0Dh,0Ah,'$'

msg_dec_ax_pass    db 'DEC AX: PASS',0Dh,0Ah,'$'
msg_dec_ax_fail    db 'DEC AX: FAIL',0Dh,0Ah,'$'
msg_dec_cx_pass    db 'DEC CX: PASS',0Dh,0Ah,'$'
msg_dec_cx_fail    db 'DEC CX: FAIL',0Dh,0Ah,'$'
msg_dec_dx_pass    db 'DEC DX: PASS',0Dh,0Ah,'$'
msg_dec_dx_fail    db 'DEC DX: FAIL',0Dh,0Ah,'$'
msg_dec_bx_pass    db 'DEC BX: PASS',0Dh,0Ah,'$'
msg_dec_bx_fail    db 'DEC BX: FAIL',0Dh,0Ah,'$'
msg_dec_sp_pass    db 'DEC SP: PASS',0Dh,0Ah,'$'
msg_dec_sp_fail    db 'DEC SP: FAIL',0Dh,0Ah,'$'
msg_dec_bp_pass    db 'DEC BP: PASS',0Dh,0Ah,'$'
msg_dec_bp_fail    db 'DEC BP: FAIL',0Dh,0Ah,'$'
msg_dec_si_pass    db 'DEC SI: PASS',0Dh,0Ah,'$'
msg_dec_si_fail    db 'DEC SI: FAIL',0Dh,0Ah,'$'
msg_dec_di_pass    db 'DEC DI: PASS',0Dh,0Ah,'$'
msg_dec_di_fail    db 'DEC DI: FAIL',0Dh,0Ah,'$'

msg_pp_ax_pass     db 'PUSH/POP AX: PASS',0Dh,0Ah,'$'
msg_pp_ax_fail     db 'PUSH/POP AX: FAIL',0Dh,0Ah,'$'
msg_pp_cx_pass     db 'PUSH/POP CX: PASS',0Dh,0Ah,'$'
msg_pp_cx_fail     db 'PUSH/POP CX: FAIL',0Dh,0Ah,'$'
msg_pp_dx_pass     db 'PUSH/POP DX: PASS',0Dh,0Ah,'$'
msg_pp_dx_fail     db 'PUSH/POP DX: FAIL',0Dh,0Ah,'$'
msg_pp_bx_pass     db 'PUSH/POP BX: PASS',0Dh,0Ah,'$'
msg_pp_bx_fail     db 'PUSH/POP BX: FAIL',0Dh,0Ah,'$'
msg_pp_sp_pass     db 'PUSH/POP SP: PASS',0Dh,0Ah,'$'
msg_pp_sp_fail     db 'PUSH/POP SP: FAIL',0Dh,0Ah,'$'
msg_pp_bp_pass     db 'PUSH/POP BP: PASS',0Dh,0Ah,'$'
msg_pp_bp_fail     db 'PUSH/POP BP: FAIL',0Dh,0Ah,'$'
msg_pp_si_pass     db 'PUSH/POP SI: PASS',0Dh,0Ah,'$'
msg_pp_si_fail     db 'PUSH/POP SI: FAIL',0Dh,0Ah,'$'
msg_pp_di_pass     db 'PUSH/POP DI: PASS',0Dh,0Ah,'$'
msg_pp_di_fail     db 'PUSH/POP DI: FAIL',0Dh,0Ah,'$'

msg_jo_pass        db 'JO: PASS',0Dh,0Ah,'$'
msg_jo_fail        db 'JO: FAIL',0Dh,0Ah,'$'
msg_jno_pass       db 'JNO: PASS',0Dh,0Ah,'$'
msg_jno_fail       db 'JNO: FAIL',0Dh,0Ah,'$'
msg_jb_pass        db 'JB: PASS',0Dh,0Ah,'$'
msg_jb_fail        db 'JB: FAIL',0Dh,0Ah,'$'
msg_jnb_pass       db 'JNB: PASS',0Dh,0Ah,'$'
msg_jnb_fail       db 'JNB: FAIL',0Dh,0Ah,'$'
msg_je_pass        db 'JE: PASS',0Dh,0Ah,'$'
msg_je_fail        db 'JE: FAIL',0Dh,0Ah,'$'
msg_jne_pass       db 'JNE: PASS',0Dh,0Ah,'$'
msg_jne_fail       db 'JNE: FAIL',0Dh,0Ah,'$'
msg_jbe_pass       db 'JBE: PASS',0Dh,0Ah,'$'
msg_jbe_fail       db 'JBE: FAIL',0Dh,0Ah,'$'
msg_ja_pass        db 'JA: PASS',0Dh,0Ah,'$'
msg_ja_fail        db 'JA: FAIL',0Dh,0Ah,'$'
msg_js_pass        db 'JS: PASS',0Dh,0Ah,'$'
msg_js_fail        db 'JS: FAIL',0Dh,0Ah,'$'
msg_jns_pass       db 'JNS: PASS',0Dh,0Ah,'$'
msg_jns_fail       db 'JNS: FAIL',0Dh,0Ah,'$'
msg_jp_pass        db 'JP: PASS',0Dh,0Ah,'$'
msg_jp_fail        db 'JP: FAIL',0Dh,0Ah,'$'
msg_jnp_pass       db 'JNP: PASS',0Dh,0Ah,'$'
msg_jnp_fail       db 'JNP: FAIL',0Dh,0Ah,'$'
msg_jl_pass        db 'JL: PASS',0Dh,0Ah,'$'
msg_jl_fail        db 'JL: FAIL',0Dh,0Ah,'$'
msg_jnl_pass       db 'JNL: PASS',0Dh,0Ah,'$'
msg_jnl_fail       db 'JNL: FAIL',0Dh,0Ah,'$'
msg_jle_pass       db 'JLE: PASS',0Dh,0Ah,'$'
msg_jle_fail       db 'JLE: FAIL',0Dh,0Ah,'$'
msg_jg_pass        db 'JG: PASS',0Dh,0Ah,'$'
msg_jg_fail        db 'JG: FAIL',0Dh,0Ah,'$'

section .bss
; empty
