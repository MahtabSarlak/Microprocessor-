; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here   

.DATA      
    MSG1 DB "ENTER YOUR FIRST NUMBER : $"
    MSG2 DB "YOUR FIRST NUMBER IS : $"        
    MSG3 DB "ENTER YOUR SECOND NUMBER : $"
    MSG4 DB "YOUR SECOND NUMBER IS : $"
    MSG5 DB "GCD IS : $" 
    NEWLINE DB 0AH,0DH,"$" 
	d1 db 100 DUP("$")
	d2 db 100 DUP("$") 
.CODE 
MAIN PROC FAR 
        
;init ds
    mov ax, @DATA 
	mov ds, ax 
	

;input number1

    lea si,d1
    
    mov ah,09H
    lea dx,MSG1
    int 21H
    
    mov ah,0AH
    mov dx,si
    int 21H
    
    mov ah,09H
    lea dx,NEWLINE
    int 21H 
    
    
;input number2

    lea si,d2
    
    mov ah,09H
    lea dx,MSG3
    int 21H
    
    mov ah,0AH
    mov dx,si
    int 21H
    
    mov ah,09H
    lea dx,NEWLINE
    int 21H  
    
    
;init ax and bx 
        

    LEA si,d2 
    add si,2   
             
    
    xor cx,cx
  
L3:
    inc si    
    inc cl
    cmp BYTE PTR[si],"$"
    jne L3
        
    LEA si,d2 
    add si,2
    dec cl               
            
    
    xor bx,bx 
    mov bl,0AH
    xor ax,ax
    xor dx,dx
  
L4:   
    mov dl,[si] 
    mul bl
    sub dl,30H 
    add ax,dx
    inc si
    loop L4 

;value of second input    
mov bp,ax
    
    
L7: 
    LEA si,d1 
    add si,2   
    
    xor cx,cx
  
L5:
    inc si    
    inc cl
    cmp BYTE PTR[si],"$"
    jne L5
        
    LEA si,d1 
    add si,2
    dec cl               
            
    
    xor bx,bx 
    mov bl,0AH
    xor ax,ax
    xor dx,dx
  
L6:   
    mov dl,[si] 
    mul bl
    sub dl,30H 
    add ax,dx
    inc si
    loop L6  
;value of first input is in ax
;move value of second input from bp to bx
mov bx,bp
    

;find gcd of two numbers 
	call GCD  
	

;print   

    mov ah,09H
    lea dx,MSG5
    int 21H 
    
;load the gcd in ax  and bp
	mov ax, cx          
	
	mov bp, cx
	
    
	call PRINT 
;load the gcd in dx	
	mov dx,bp

;int exit
	mov ah, 4CH 
	int 21H 

MAIN ENDP 
	
GCD PROC 

	 cmp bx, 0 
	 jne continue

;if bx 0 then gcd is ax and return
	mov cx, ax 
	ret 
   
;calc gcd
continue: 

	xor dx, dx 

	div bx 
	mov ax, bx 
	mov bx, dx 

;call gcd 
	call GCD 
	ret 
	
GCD ENDP  


	
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




