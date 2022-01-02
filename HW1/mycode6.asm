
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here    

.DATA
    arr Db 5H,10H,2H,9H,3H,7H,45H,35H,89H,23H,90H,0A1H,12H,1H,66H,30H,54H,11H,0BAH,0BBH,0CAH,0CDH,0DH,75H,0D7H     
    MSG DB "SORTED ARRAY : $"
    num Db ?
    lenght DW 25
.CODE
MAIN PROC FAR  
    mov ax,@data
    mov ds,ax   
  
    mov cx,0 
    mov si,cx
    mov bx,1000H    
L4:       
    mov dl,arr[si]
    mov [bx],dl
    inc bx
    inc cx       
    mov si ,cx
    cmp cx,lenght
    jl  L4
    
    
    mov cx,1 
    xor bx,bx  
first_loop:
    cmp cx,lenght
    jae print_loop
    mov si,cx
    mov bl,1000H+[si] 
    mov num,bl
    mov ax,cx
    dec ax
second_loop:
    mov si,ax
    mov bl,[si]+1000H
    cmp num,bl
    jae L1
    jb  swap
     
L1:
    inc ax 
    mov si,ax  
    mov bl,num
    ;mov arr[si]+,bl   
    mov [si]+1000H,bl
    inc cx
    jmp first_loop
swap:
    mov si,ax
    inc si  
    ;mov arr[si],bl 
    mov [si]+1000H,bl
    dec ax
    cmp ax,0H
    jl  L1
    jmp second_loop

print_loop: 
    mov ah,09H
    lea dx,MSG
    int 21H 
    
    xor ax,ax
    mov si,0
L2:   
    xor ax,ax
    cmp si,lenght
    jae int_exit
    mov al,[si]+1000H 
    
    call PRINT
     
    mov dl, ' '
    mov ah, 02H
    int 21h 
    
    inc si
    jmp L2
int_exit:
	mov ah, 4CH 
	int 21H    


MAIN ENDP
PRINT PROC 

	mov cx, 0
	mov dx, 0 
	
label1: 

	cmp ax, 0 
	je print1 

    mov bx, 10 
	div bx 

;push it in stack 
	push dx 

	inc cx 
 
	xor dx, dx 
	jmp label1 
print1: 

	cmp cx, 0 
	je exit

;pop the top of stack 
	pop dx 
	add dx, 48 

;int print 
	mov ah, 02h
	int 21h
 
	dec cx 
	jmp print1 
exit:
    ret 
	PRINT ENDP 
ENDS MAIN
ret




