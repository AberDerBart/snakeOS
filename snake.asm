org 0x0000
bits 16

section .code

;initialize ds- and es-register
mov bx,cs
mov es,bx
mov ds,bx

;set screen mode
mov ah,0x0
mov al,0x2
int 0x10

;make cursor invisible
mov ah,0x1
mov ch,0xff
mov cl,0xff
int 0x10

;mov cursor to score position
mov dl,77
mov dh,0
mov ah,0x02
mov bh,0
int 0x10

;draw score (000)
mov al,'0'
mov cx,3
mov ah,0x0a
int 0x10

;move cursor to tail position
mov dl,[tx]
mov dh,[ty]
mov ah,0x02
int 0x10

;print initial tail
mov cl,[hx]
sub cl,[tx]
inc cl
mov cl,5
mov ch,0x0
mov ah,0x0a
mov al,205
int 0x10

;tempfood
mov dl,20
mov dh,20
mov al,'*'
mov ah,2
mov cx,1
int 0x10
mov ah,0x0a
int 0x10

mainloop:

;backup moving direction
mov ax,[dir]
mov [dir2],ax

;check if key was pressed
getkey:
mov ah,0x1
int 0x16
jz nokey

;if yes, check which key was pressed...
mov ah,0x0
int 0x16
cmp al,'w'
jz keyw
cmp al,'a'
jz keya
cmp al,'s'
jz keys
cmp al,'d'
jz keyd
jmp getkey

;...and set the direction accordingly
keyw:
cmp word [dir],0x0100
jz nokey
mov word [dir],0xff00
jmp nokey
keya:
cmp word [dir],0x0001
jz nokey
mov word [dir],0xff
jmp nokey
keys:
cmp word [dir],0xff00
jz nokey
mov word [dir],0x0100
jmp nokey
keyd:
cmp word [dir],0x00ff
jz nokey
mov word [dir],0x0001
nokey:

;move head

;set position
mov dh,[hy]
mov dl,[hx]
mov ah,0x2
int 0x10

;check movement direction
mov ax,[dir2]
cmp ax,0x0001
jz fromleft
cmp ax,0x00ff
jz fromright
cmp ax,0x0100
jz fromtop
	mov ax,[dir]
	cmp ax,0x0001
	jz frombottomtoright
	cmp ax,0x00ff
	jz frombottomtoleft
		mov al,186
		jmp drawtailpiece
	fromrighttobottom:
	frombottomtoright:
		mov al,201
		jmp drawtailpiece
	fromlefttobottom:
	frombottomtoleft:
		mov al,187
		jmp drawtailpiece
fromleft:
	mov ax,[dir]
	cmp ax,0x0100
	jz fromlefttobottom
	cmp ax,0xff00
	jz fromlefttotop
		mov al,205
		jmp drawtailpiece
	fromlefttotop:
	fromtoptoleft:
		mov al,188
		jmp short drawtailpiece
fromright:
	mov ax,[dir]
	cmp ax,0x0100
	jz fromrighttobottom
	cmp ax,0xff00
	jz fromrighttotop
		mov al,205
		jmp drawtailpiece
	fromrighttotop:
	fromtoptoright:
		mov al,200
		jmp drawtailpiece
fromtop:
	mov ax,[dir]
	cmp ax,0x0001
	jz fromtoptoright
	cmp ax,0x00ff
	jz fromtoptoleft
		mov al,0xba

;draw the tailpiece
drawtailpiece:
mov ah,0xa
mov bh,0x0
mov cx,0x1
int 0x10

;set new head position
add dl,[dir]
add dh,[dir+1]
mov [hx],dl
mov [hy],dh
mov ah,0x2
mov bh,0x0
int 0x10

cmp dh,24
jg gameover
cmp dl,79
jg gameover
cmp dl,0
jl gameover
cmp dh,0
jl gameover

;get next field
mov ah,0x8
int 0x10
mov [temp], al

;draw head
mov ah,0xa
mov al,0x1
mov cx,0x1
int 0x10

;check for collision
cmp byte [temp],'*'
je eat
cmp byte [temp],32
jne gameover

;grow if nessecary
cmp byte [togrow],0
jg grow

;move tail

;get tailtip
mov dl,[tx]
mov dh,[ty]
mov ah,0x2
int 0x10
mov ah,0x8
int 0x10
mov cx,[dirt]
cmp cx,0x0001
jz t_fromleft
cmp cx,0x00ff
jz t_fromright
cmp cx,0xff00
jz t_frombottom
	cmp al,186
	jz t_fromtoptobottom
	cmp al,188
	jz t_fromtoptoleft
	t_toright:
		mov word [dirt],0x0001
		jmp deltailtip
t_fromleft:
	cmp al,205
	jz t_fromlefttoright
	cmp al,188
	jz t_fromlefttotop
	t_tobottom:
		mov word [dirt],0x0100
		jmp deltailtip
	t_fromrighttotop:
	t_fromlefttotop:
		mov word [dirt],0xff00
		jmp deltailtip
t_fromright:
	cmp al,205
	jz t_fromrighttoleft
	cmp al,200
	jz t_fromrighttotop 
	jmp t_tobottom
t_frombottom:
	cmp al,186
	jz t_frombottomtotop
	cmp al,187
	jz t_frombottomtoleft
	jmp t_toright
	t_fromtoptoleft:
	t_frombottomtoleft:
		mov word [dirt],0x00ff

t_frombottomtotop:
t_fromrighttoleft:
t_fromlefttoright:
t_fromtoptobottom:
deltailtip:

;remove the tailtip
mov al,32
mov cx,0x1
mov ah,0xa
int 0x10
add dl,[dirt]
add dh,[dirt+1]
mov [tx],dl
mov [ty],dh

eaten:;dont remove tailtip

;wait for a while
mov ah,0x1
mov cx,0x0
mov dx,0x0
int 0x1a
mov ah,0x0
sleep:
int 0x1a
cmp dx,0x002
jl sleep

;restart loop
jmp mainloop

;generate new food

eat:
;(pseudo-)random x-var
mov ax,[random]
mul word [seed]
add ax,[seed2]
mov cl,ah
modloop1:
sub cl,80
cmp cl,80
jge modloop1
cmp cl,0
jl modloop1
;(pseudo-)random y-var
mul word [seed]
add ax,[seed2]
mov [random],ax
mov dh,ah
modloop2:
sub dh,25
cmp dh,25
jge modloop2
cmp dh,0
jl modloop2
;move cursor to generated position
mov dl,cl
mov ah,0x02
mov bh,0
int 0x10
;make sure field is empty
mov ah,0x08
mov bh,0
int 0x10
cmp al,32
jne eat
;print food
mov al,'*'
mov ah,0x0a
mov cx,1
int 0x10
;increase size and score
add byte [togrow],5
inc word [score]

printscore:
;move cursor to scoreboard
mov dl,77
mov dh,0
mov bh,0
mov ah,0x02
int 0x10
mov cx,[score]
call printword

grow:
dec  byte [togrow]
jmp eaten

gameover:
mov cx,[top5name]
mov ax,[score]
cmp ax,[top5score]
jle no5

mov ah,0
mov al,2
int 0x10
mov si,reachedhighscorestring
call print
mov di,[top5name]
call input
mov cx,[top5name]
mov ax,[score]


cmp ax,[top4score]
jle no4
cmp ax,[top3score]
jle no3
cmp ax,[top2score]
jle no2
cmp ax,[top1score]
jle no1
mov bx,[top1score]
mov [top1score],ax
mov ax,bx
mov bx,[top1name]
mov [top1name],cx
mov cx,bx
no1:
mov bx,[top2score]
mov [top2score],ax
mov ax,bx
mov bx,[top2name]
mov [top2name],cx
mov cx,bx
no2:
mov bx,[top3score]
mov [top3score],ax
mov ax,bx
mov bx,[top3name]
mov [top3name],cx
mov cx,bx
no3:
mov bx,[top4score]
mov [top4score],ax
mov ax,bx
mov bx,[top4name]
mov [top4name],cx
mov cx,bx
no4:
mov [top5score],ax
mov [top5name],cx

no5:

;set screen mode/clear screen
mov al,0x02
mov ah,0x00
int 0x10

;make cursor invisible
mov ah,0x1
mov ch,0xff
mov cl,0xff
int 0x10

;print highscore
mov si, highscorestring
call print
mov si,top1string
call print
mov si,[top1name]
call print
mov cx,[top1score]
call printword
mov si,top2string
call print
mov si,[top2name]
call print
mov cx,[top2score]
call printword
mov si,top3string
call print
mov si,[top3name]
call print
mov cx,[top3score]
call printword
mov si,top4string
call print
mov si,[top4name]
call print
mov cx,[top4score]
call printword
mov si,top5string
call print
mov si,[top5name]
call print
mov cx,[top5score]
call printword

mov byte [hx],10
mov byte [hy],10
mov byte [tx],5
mov byte [ty],10
mov word [dir],0x0001
mov word [dir2],0x0001
mov word [dirt],0x0001
mov byte [temp],0
mov byte [togrow],0
mov word [score],0

mov ah,0x03
mov al,3
mov ch,0
mov cl,2
mov dh,0
mov dl,0
mov bx,0x1000
mov es,bx
mov bx,0x0000
int 0x13


jmp $

print:
mov ah,0x0e
print_next:
lodsb
test al,al
jne print_cont
ret
print_cont:
int 0x10
inc cx
jmp print_next

printword:
;print x--
mov ax,cx
mov bl,100
div bl
add al,0x30
mov ah,0x0e
int 0x10
;print -x-
mov ax,cx
mov bl,10
div bl
xor ah,ah
div bl
mov al,ah
add al,0x30
mov ah,0x0e
int 0x10
;print --x
mov ax,cx
mov bl,10
div bl
mov al,ah
mov ah,0x0e
add al,0x30
int 0x10
ret

input:
mov dl,16
input_loop:
test dl,dl
je input_end
dec dl
mov ah,0x00
int 0x16
cmp al,13
je input_end
mov ah,0x0e
int 0x10
cmp al,8
jne input_save
dec di
inc dl
jmp input_loop
input_save:
stosb
jmp input_loop
input_end:
mov cl, dl
inc cl
mov ch,0
mov al,32
input_end_loop:
stosb
loop input_end_loop
ret

data section .data

;variables
hx db 10
hy db 10
tx db 05
ty db 10
dir dw 0x0001
dir2 dw 0x0001
dirt dw 0x0001
temp db 0
seed dw 20077
seed2 dw 12345
random dw 0x4943
togrow db 0
score dw 0
reachedhighscorestring db "You have reached top 5, enter your name (max. 16 characters)!",10,13,10,13,0
highscorestring db "Highscore",0
top1string db 10,13,10,13,"1. ",0
top1score dw 0
top1name dw name1
top2string db 10,13,10,13,"2. ",0
top2score dw 0
top2name dw name2
top3string db 10,13,10,13,"3. ",0
top3score dw 0
top3name dw name3
top4string db 10,13,10,13,"4. ",0
top4score dw 0
top4name dw name4
top5string db 10,13,10,13,"5. ",0
top5score dw 0
top5name dw name5
name1 db "                ",32,0
name2 db "                ",32,0
name3 db "                ",32,0
name4 db "                ",32,0
name5 db "                ",32,0
