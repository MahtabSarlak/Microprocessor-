
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here
.DATA   
    MSG1 DB "ENTER YOUR NUMBER : $" 
    MSG3 DB "YOUR SQUARE ROOT IS : $"  
    NEWLINE DB 0AH,0DH,"$" 
    num db 100 DUP("$") 
    result   DD  ? ;


.CODE

MAIN    PROC
   
    mov ax, @DATA;
    mov ds,ax;
              
              
;INPUT NUMBER  

    lea si,num  
    
    mov ah,09h
    lea dx,MSG1
    int 21h
    
    mov ah,0Ah
    mov dx,si
    int 21h

    mov ah , 09h
    lea dx,NEWLINE
    int 21h   
    
;init ax with number 
        

    LEA si,num 
    add si,2   
             
    
    xor cx,cx
  
L1:
    inc si    
    inc cl
    cmp BYTE PTR[si],"$"
    jne L1
        
    LEA si,num
    add si,2
    dec cl               
            
    
    xor bx,bx 
    mov bl,0AH
    xor ax,ax
    xor dx,dx
  
L2:   
    mov dl,[si] 
    mul bl
    sub dl,30H 
    add ax,dx
    inc si
    loop L2  

;find square root    
    
    mov bx,ax
    xor cx,cx

L3:    
    mov ax,cx
    mul cx
    cmp ax,bx
    jz  L4
    inc cx
    jnz L3
L4:  
;print result 

    mov ah,09h
    lea dx,MSG1
    int 21h
    
    mov ax,cx
    call PRINT
    
;int exit
    mov ah, 4CH 
    int 21H 
      
MAIN  ENDP   
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

;print 
	mov ah, 02h
	int 21h 


	dec cx 
	jmp print1 
exit:
    ret 
    
PRINT ENDP  
END MAIN
ret




