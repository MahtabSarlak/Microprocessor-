
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here  

.DATA 
        MSG1 DB "ENTER YOUR STRING : $"
        MSG2 DB "YOUR STRING IS : $"
        MSG3 DB "UPPERCASE STRING IS : $"
        str  DB 20 DUP ("$")
        ustr DB 20 DUP("$")
        NEWLINE DB 0AH,0DH,"$" 
        


.CODE
        
MAIN PROC FAR

;init ds
    mov ax, @DATA 
	mov ds, ax 
	
	lea si,str

;input string  

    lea si,str  
    
    mov ah,09h
    lea dx,MSG1
    int 21h
    
    mov ah,0Ah
    mov dx,si
    int 21h

    mov ah , 09h
    lea dx,NEWLINE
    int 21h  



;to uppercase
    
    mov ah,09h
    lea dx,MSG3
    int 21h    

    LEA si,str 
    add si,2              
    
    xor cx,cx
  
L1:
    inc si    
    inc cl
    cmp BYTE PTR[si],"$"
    jne L1
        
    LEA si,str 
    add si,2
    dec cl               
          
    xor ax,ax  
    lea di,ustr

L2:  
    mov al,BYTE PTR[si] 
    cmp al,61H
    jl L3
    sub al,20H
    
    L3:    
    mov BYTE PTR[di],al
    
    inc si
    inc di
    loop L2    
    
    mov al , "$"
    mov BYTE PTR[di],al
    
    mov ah,09h
    lea dx,ustr
    int 21h

;int exit
	mov ah, 4CH 
	int 21H 

ret




