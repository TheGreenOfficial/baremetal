ORG 0X7C00
BITS 16

jmp start

message: db 'Yellow, World!', 0

print_char:
    mov al, [si]
    cmp al, 0
    je done
    int 0x10
    inc si
    jmp print_char

start:
    mov ah, 0x0e
    mov si, message
    call print_char

done:
    jmp $

times 510-($ - $$) db 0
dw 0xAA55
