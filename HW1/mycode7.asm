
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here
  
.DATA   
    MSG1 DB "ENTER YOUR NUMBER : $" 
    MSG2 DB "NTH FIBONACCI NUMBER IS : $"  
    NEWLINE DB 0AH,0DH,"$" 
    n db 100 DUP("$") 
    default db "0$" 
    res db 100 DUP("$") 
    result   DD  ? ;


.CODE

MAIN    PROC
   
    mov ax, @DATA;
    mov ds,ax;
              
              
;INPUT NUMBER  

    lea si,n  
    
    mov ah,09h
    lea dx,MSG1
    int 21h
    
    mov ah,0Ah
    mov dx,si
    int 21h

    mov ah , 09h
    lea dx,NEWLINE
    int 21h   
    
;init ax with n 
        

    LEA si,n 
    add si,2   
             
    
    xor cx,cx
  
L1:
    inc si    
    inc cl
    cmp BYTE PTR[si],"$"
    jne L1
        
    LEA si,n
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
    
;call fibo function
    lea si,res
    mov cx,ax
    mov bx,00H  
    
;find fib 
     
	call FIB  
	

;print   
    mov ah,09H
    lea dx,MSG2
    int 21H 
    
    cmp cx,00H
    je  L4 
    
    mov ax, bx
	call PRINT
	jmp L5 
L4:
    mov ah,09H
    lea dx,default
    int 21H     

L5:
;int exit
	mov ah, 4CH 
	int 21H 

MAIN ENDP 
	
FIB PROC 

   cmp   cx, 1
   jg    L3 
   mov   ax,00H
   mov   bx,01H
   ret
	
L3:
   dec   cx
   call  FIB
   add   ax,bx
   mov   dx,bx
   mov   bx,ax
   mov   ax,dx
   ret
	
FIB ENDP  

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
END MAIN
             
  
ret




