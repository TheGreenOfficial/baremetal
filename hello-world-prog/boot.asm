ORG 0x7C00
BITS 16

jmp start                     ; jump to start so now it starts executing there cont read there..

message: db 'Yellow, World!', 0 ; message is lebal db is define byte or data storage (The directive that reserves the memory.) that keeps ascii's - string and ending with null terminator 0x00

print_char:
    mov al, [si]              ; get current character
    cmp al, 0                 ; reached the end of the string or found 0x00
    je done                   ; if yes, stop printing and jump to done else do nothing
    int 0x10                  ; bios teletype prints the character in al register
    inc si                    ; move/point to the next character in that pointer si
    jmp print_char            ; keep printing until it hits jz ..

start:
    mov ah, 0x0e              ; bios teletype function.. 0eh is video register..
    mov si, message           ; si points to the string alike pointer is c first char of the string alr that message lebel is defined at 6th line wath that..
    call print_char           ; call print char fucntions that prints full message label cont .. at

done:
    jmp $                     ; stay here forever or jump to itself

times 510-($ - $$) db 0       ; fill the rest of the boot sector with zeros nasm does it its sintax
dw 0xAA55                     ; boot signature so BIOS knows it's bootable in little-endian
