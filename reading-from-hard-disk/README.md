**I understood the concept of reading form hard disk like this - just read it if you are interested:**
<br><br>
<img width="2976" height="3968" alt="IMG_20260723_235813_708" src="https://github.com/user-attachments/assets/93d4efaf-500d-40c6-88ae-d88fc0a16bed" />
<br><br>
**also i wrote this while learning/trying to understand things self taught from internet so i may be wrong at some little areas that i made assumptions myself to make me understand idk jsut bear with it idk..**


<br>

**adding ai explanation of code in comments:**
```
ORG 0                   ; NASM: pretend this program starts at offset 0
BITS 16                 ; Generate 16-bit instructions

_start:
    jmp short start     ; Skip over the data below and go to "start"
    nop                 ; No Operation (does absolutely nothing)
                        ; Traditionally boot sectors begin with JMP + NOP

times 33 db 0           ; Reserve 33 bytes filled with 0
                        ; Later these become the FAT BIOS Parameter Block (BPB)
                        ; Right now they're just empty placeholders

boot_drive db 0         ; Reserve 1 byte variable
                        ; We'll store BIOS's boot drive number here

;=========================================================

start:

    ; FAR JUMP
    ; Changes BOTH CS (Code Segment) and IP (Instruction Pointer)
    ; Execution now officially continues in segment 0x7C0
    jmp 0x7C0:step2

;=========================================================

step2:

    cli                 ; Clear Interrupt Flag
                        ; Disable hardware interrupts while setting stack

    mov ax,0x7C0        ; AX = 0x7C0

    mov ds,ax           ; DS (Data Segment) = 0x7C0
                        ; Variables like [boot_drive] now use this segment

    mov es,ax           ; ES (Extra Segment) = 0x7C0
                        ; BIOS disk reads use ES:BX

    xor ax,ax           ; AX = 0
                        ; Faster/smaller than "mov ax,0"

    mov ss,ax           ; SS (Stack Segment) = 0

    mov sp,0x7C00       ; SP (Stack Pointer) = 0x7C00
                        ; Stack starts at physical address 0000:7C00
                        ; Stack grows DOWN

    mov [boot_drive],dl ; BIOS gave us boot drive number in DL
                        ; Save it because BIOS calls may overwrite DL

    sti                 ; Set Interrupt Flag
                        ; Enable interrupts again

;=========================================================
; BIOS DISK READ
;=========================================================

    mov ah,2            ; INT 13h Function 02h
                        ; = Read sectors

    mov al,1            ; Read 1 sector (512 bytes)

    mov ch,0            ; Cylinder 0

    mov cl,2            ; Sector number 2
                        ; Sector 1 = bootloader
                        ; Sector 2 = next sector

    mov dh,0            ; Head 0

    mov dl,[boot_drive] ; Restore drive number

    mov bx,buffer       ; BX = address where BIOS should copy data
                        ; BIOS uses ES:BX as destination

    int 13h             ; Call BIOS disk service

    jc error            ; JC = Jump if Carry
                        ; Carry Flag = 1 means disk read failed

;=========================================================

    mov si,buffer       ; SI now points to loaded data

    call print          ; Print loaded text

    jmp $               ; Infinite loop

;=========================================================

error:

    mov si,error_message

    call print

    jmp $

;=========================================================
; PRINT STRING
;=========================================================

print:

.loop:

    lodsb               ; AL = [DS:SI]
                        ; SI++
                        ; Same as:
                        ; mov al,[si]
                        ; inc si

    cmp al,0            ; Is character NULL?

    je .done            ; Yes -> finished string

    call print_char     ; Print character in AL

    jmp .loop           ; Next character

.done:

    ret                 ; Return to caller

;=========================================================
; PRINT ONE CHARACTER
;=========================================================

print_char:

    mov ah,0x0E         ; BIOS video function
                        ; Function 0Eh = print character in AL

    int 10h             ; BIOS prints AL

    ret

;=========================================================

error_message db "failed to load sector..",0
                        ; NULL terminated string

;=========================================================

times 510-($-$$) db 0
; $  = current position
; $$ = beginning of program
;
; ($-$$) = bytes we've already used
;
; Fill remaining bytes with 0 until byte 510

dw 0xAA55
; Boot Signature
; BIOS checks last two bytes of sector
; Actually stored as:
; 55 AA
; because x86 is little-endian

;=========================================================

buffer:
; Label immediately AFTER the boot sector.
;
; BIOS loads Sector 2 here.
;
; RAM Layout:
;
; 0x7C00 -------------------------
; | Bootloader (512 bytes)       |
; -------------------------------
; 0x7E00 <- buffer starts here
; | Sector 2 loaded here         |
; -------------------------------
```
