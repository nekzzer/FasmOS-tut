org 7C00h
use16

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 7C00h

    mov ax, 0003h
    int 10h

    mov ah, 02h
    mov bx, 0800h
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 80h
    mov al, 4
    mov es, ax
    xor ax, ax
    mov es, ax
    mov bx, 7E00h
    mov ax, 0204h
    int 13h

    jmp stage2

times 510 - ($ - $$) db 0
dw 0AA55h

stage2:
    mov si, welcome_msg
    call print_string

    mov si, separator
    call print_string

command_loop:
    mov si, prompt
    call print_string

    mov di, input_buffer
    xor cx, cx

read_key:
    xor ah, ah
    int 16h

    cmp al, 0Dh
    je enter_pressed

    cmp al, 08h
    je backspace

    cmp cl, 63
    je read_key

    stosb
    inc cl

    mov ah, 0Eh
    xor bh, bh
    mov bl, [current_color]
    int 10h

    jmp read_key

backspace:
    test cl, cl
    jz read_key

    dec di
    dec cl

    mov ah, 0Eh
    mov al, 08h
    xor bh, bh
    int 10h

    mov al, ' '
    int 10h

    mov al, 08h
    int 10h

    jmp read_key

enter_pressed:
    mov byte [di], 0
    call newline

    cmp byte [input_buffer], 0
    je command_loop

    mov si, input_buffer
    mov di, cmd_help
    call strcmp
    jc do_help

    mov si, input_buffer
    mov di, cmd_clear
    call strcmp
    jc do_clear

    mov si, input_buffer
    mov di, cmd_info
    call strcmp
    jc do_info

    mov si, input_buffer
    mov di, cmd_color
    call strcmp
    jc do_color

    mov si, input_buffer
    mov di, cmd_reboot
    call strcmp
    jc do_reboot

    mov si, input_buffer
    mov di, cmd_halt
    call strcmp
    jc do_halt

    mov si, input_buffer
    mov di, cmd_echo
    call strcmp_prefix
    jc do_echo

    mov si, input_buffer
    mov di, cmd_time
    call strcmp
    jc do_time

    mov si, input_buffer
    mov di, cmd_mem
    call strcmp
    jc do_mem

    mov si, unknown_msg
    call print_string
    jmp command_loop

do_help:
    mov si, help_text
    call print_string
    jmp command_loop

do_clear:
    mov ax, 0003h
    int 10h
    jmp command_loop

do_info:
    mov si, info_text
    call print_string
    jmp command_loop

do_color:
    inc byte [current_color]
    cmp byte [current_color], 16
    jb .ok
    mov byte [current_color], 1
.ok:
    mov si, color_msg
    call print_string
    jmp command_loop

do_reboot:
    mov si, reboot_msg
    call print_string
    xor ah, ah
    int 16h
    jmp 0FFFFh:0000h

do_halt:
    mov si, halt_msg
    call print_string
.lp:
    hlt
    jmp .lp

do_echo:
    mov si, input_buffer
    add si, 5
.skip:
    cmp byte [si], ' '
    jne .print
    inc si
    jmp .skip
.print:
    call print_string
    call newline
    jmp command_loop

do_time:
    mov ah, 02h
    int 1Ah
    mov al, ch
    call print_bcd
    mov al, ':'
    call print_char
    mov al, cl
    call print_bcd
    mov al, ':'
    call print_char
    mov al, dh
    call print_bcd
    call newline
    jmp command_loop

do_mem:
    int 12h
    call print_number
    mov si, mem_suffix
    call print_string
    jmp command_loop

print_string:
    pusha
.lp:
    lodsb
    test al, al
    jz .done
    mov ah, 0Eh
    xor bh, bh
    mov bl, [current_color]
    int 10h
    jmp .lp
.done:
    popa
    ret

print_char:
    mov ah, 0Eh
    xor bh, bh
    mov bl, [current_color]
    int 10h
    ret

newline:
    pusha
    mov ah, 0Eh
    mov al, 0Dh
    xor bh, bh
    int 10h
    mov al, 0Ah
    int 10h
    popa
    ret

strcmp:
    pusha
    push si
    push di
.lp:
    lodsb
    mov ah, [di]
    inc di
    cmp al, ah
    jne .ne
    test al, al
    jz .eq
    jmp .lp
.eq:
    pop di
    pop si
    popa
    stc
    ret
.ne:
    pop di
    pop si
    popa
    clc
    ret

strcmp_prefix:
    pusha
    push si
    push di
.lp:
    mov ah, [di]
    test ah, ah
    jz .match
    lodsb
    cmp al, ah
    jne .no
    inc di
    jmp .lp
.match:
    pop di
    pop si
    popa
    stc
    ret
.no:
    pop di
    pop si
    popa
    clc
    ret

print_bcd:
    push ax
    mov ah, al
    shr al, 4
    add al, '0'
    call print_char
    mov al, ah
    and al, 0Fh
    add al, '0'
    call print_char
    pop ax
    ret

print_number:
    pusha
    xor cx, cx
    mov bx, 10
.div:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .div
.pr:
    pop dx
    mov al, dl
    add al, '0'
    call print_char
    loop .pr
    popa
    ret

current_color db 0Ah

welcome_msg db 'FasmOS v0.2', 0Dh, 0Ah
            db 'Type "help" for commands', 0Dh, 0Ah, 0

separator   db '------------------------', 0Dh, 0Ah, 0

prompt      db 0Dh, 0Ah, 'FasmOS> ', 0

cmd_help    db 'help', 0
cmd_clear   db 'clear', 0
cmd_info    db 'info', 0
cmd_color   db 'color', 0
cmd_reboot  db 'reboot', 0
cmd_halt    db 'halt', 0
cmd_echo    db 'echo ', 0
cmd_time    db 'time', 0
cmd_mem     db 'mem', 0

help_text   db 'Commands:', 0Dh, 0Ah
            db ' help   - show help', 0Dh, 0Ah
            db ' clear  - clear screen', 0Dh, 0Ah
            db ' info   - system info', 0Dh, 0Ah
            db ' color  - change color', 0Dh, 0Ah
            db ' echo   - print text', 0Dh, 0Ah
            db ' time   - show time', 0Dh, 0Ah
            db ' mem    - memory size', 0Dh, 0Ah
            db ' reboot - reboot', 0Dh, 0Ah
            db ' halt   - shutdown', 0Dh, 0Ah, 0

info_text   db 'FasmOS v0.2', 0Dh, 0Ah
            db '16-bit Real Mode', 0Dh, 0Ah
            db 'Written in FASM', 0Dh, 0Ah, 0

color_msg   db 'Color changed!', 0Dh, 0Ah, 0
reboot_msg  db 'Press any key...', 0Dh, 0Ah, 0
halt_msg    db 'System halted.', 0Dh, 0Ah, 0
unknown_msg db 'Unknown command', 0Dh, 0Ah, 0
mem_suffix  db ' KB memory', 0Dh, 0Ah, 0

input_buffer rb 64

times 2560 - ($ - $$) db 0