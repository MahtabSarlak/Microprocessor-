
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here
.DATA   
    MSG1 DB "ENTER YOUR NUMBER : $" 
    RES1 DB "NUMBER IS PALINDROME$"
    RES2 DB "NUMBER IS NOT PALINDROME$" 
    NEWLINE DB 0AH,0DH,"$" 
    n db 100 DUP("$") 
    res db 100 DUP("$") 


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
  
L3:
    inc si    
    inc cl
    cmp BYTE PTR[si],"$"
    jne L3
        
    LEA si,n
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
            
;binary representation of a number 
    xor cx,cx       
               
L5:
    cmp ax,0
    jle L6
    mov bx,ax
    and bl,1H  
    mov si,cx
    mov res[si],bl
    inc cx
    shr ax,1
    jmp L5                    

L6:
;check is palindrome               
    mov si,cx
    dec si
    mov di,0           
L9:  
    cmp di,si
    jge L7   
    mov bl,res[di]
    cmp bl,res[si]
    jne L8
    inc di
    dec si
    jmp L9  

; is palindrome
L7:
    mov ah,09H
    lea dx,RES1
    int 21H       
	mov dx,1
	jmp exit
; is not palindrome
L8:
    mov ah,09H
    lea dx,RES2
    int 21H
	mov dx,0
	jmp exit            
                
exit:    
      ;int exit
    mov ah, 4CH 
    int 21H 
MAIN  ENDP   

END MAIN
    
ret









