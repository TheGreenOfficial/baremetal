ORG 0
BITS 16

_start:
    jmp short start
    nop

times 33 db 0

boot_drive db 0

start:
    jmp 0x7C0:step2

step2:
    cli
    mov ax, 0x7C0
    mov ds, ax
    mov es, ax

    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [boot_drive], dl
    sti

    mov ah, 2
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    mov bx, buffer
    int 0x13
    jc error

    mov si, buffer
    call print

    jmp $

error:
    mov si, error_message
    call print
    jmp $

print:
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop

.done:
    ret

print_char:
    mov ah, 0x0E
    int 0x10
    ret

error_message db "failed to load sector..",0

times 510-($-$$) db 0
dw 0xAA55

buffer: