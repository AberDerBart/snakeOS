org 0x7c00
bits 16


;reset floppy drive
mov al,0
mov ah,0
int 0x13

mov ah,2
mov al,3
mov ch,0
mov cl,2
mov dh,0
mov dl,0
mov bx,0x1000
mov es,bx
mov bx,0x0000
int 0x13

jc error
jmp 0x1000:0x0000

error:
int 0x19


TIMES 510-($-$$) db 0x00
dw 0xAA55