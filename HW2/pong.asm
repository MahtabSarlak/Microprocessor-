STACK SEGMENT PARA STACK
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
	
	LOSE_MSG DB "GAME OVER !! $"
	WIN_MSG DB  "YOU WIN !! $"
	
	SCORE DB 0
	
    COLOR DB 0FH
	
	IS_OVER DB 0H
	
	WIN_POINT DB 01EH   
	
	WINDOW_WIDTH DW 140H
	WINDOW_HEIGHT DW 0C8H
	
	WINDOW_BOUNDS DW 0AH 
	
	WINDOW_BOUNDS_Y DW 014H
	
	TIME_AUX DB 0 ;checking if time change
	
	
	BALL_ORIGINAL_X DW 0A0H       
	BALL_ORIGINAL_Y DW 64H
	BALL_X DW 1Ah 
	BALL_Y DW 1Ah 
	BALL_SIZE DW 04h 
	BALL_VELOCITY_X DW 04h 
	BALL_VELOCITY_Y DW 02h 
	
	                         
	PADDLE_RIGHT_X DW 130H
	PADDLE_RIGHT_Y DW 014H 
	                         
	PADDLE_WIDTH DW 05H
	PADDLE_HEIGHT DW 1FH
	
	PADDLE_VELOCITY DW 05H    
	
	
	BOX_LEFT_X DW 0AH
	BOX_LEFT_Y DW 014H   ;
	
	BOX_WIDTH DW 04H
	BOX_HEIGHT DW 0AAH  ;window_height - 2*0AH 
	
    BOX_TOP_X DW 0EH
	BOX_TOP_Y DW 014H     ;
	BOX_BOTTOM_X DW 0EH
	BOX_BOTTOM_Y DW 0BAH
	 
	BOX_WIDTH_HORIZANTAL DW 0120H
	BOX_HEIGHT_HORIZANTAL DW 04H

DATA ENDS  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;Main
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE SEGMENT PARA 'CODE'

	MAIN PROC FAR
	ASSUME CS:CODE,DS:DATA,SS:STACK ;assume as code,data and stack segments the respective registers
	PUSH DS                         ;push to the stack the DS segment
	SUB AX,AX                       ;clean the AX register
	PUSH AX                         ;push AX to the stack
	MOV AX,DATA                     ;save on the AX register the contents of the DATA segment
	MOV DS,AX                       ;save on the DS segment the contents of AX
	POP AX                          ;release the top item from the stack to the AX register
	POP AX                          ;release the top item from the stack to the AX register
		     
    XOR AX,AX
    MOV SCORE,AL  
    
    
    CALL CLEAR_SCREEN  
    
    
    
CHECK_TIME:    
    XOR AX,AX 
    MOV AH,2CH ;get system time                             
    INT 21H   
    
    CMP DL,TIME_AUX
    JE  CHECK_TIME
    
     
    MOV TIME_AUX,DL 
    
    CALL CLEAR_SCREEN  
    
    CALL PRINT_SCORE
    
    CALL MOVE_BALL
    
    CALL MOVE_PADDLE
    
    CALL DRAW_BOX
    
    CALL DRAW_PADDLE
         
    CALL DRAW_BALL 
    
    CMP IS_OVER,01H
    JE OVER
    
    JMP CHECK_TIME    
    
    OVER :           
    
    CALL GAME_OVER_PAGE
    
    
RET                   
MAIN ENDP
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;draw ball
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DRAW_BALL PROC NEAR
    MOV CX,BALL_X ;init
    MOV DX,BALL_Y ;init
DRAW_H:    
    MOV AH,0CH   ;write a white pixel 
    MOV AL,0FH
    MOV BH,00H
    INT 10H 
    
    INC CX
    MOV AX,CX
    SUB AX,BALL_X
    CMP AX,BALL_SIZE
    JNG DRAW_H 
    
    MOV CX,BALL_X
    INC DX  
    
    MOV AX,DX
    SUB AX,BALL_Y
    CMP AX,BALL_SIZE
    JNG DRAW_H
    
  RET
DRAW_BALL ENDP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;CLEAR_SCREEN
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CLEAR_SCREEN PROC NEAR
   mov AH, 00         ; set video mode 
    MOV AL,13H        ; graphic mode
    int 10h       
    
    MOV AH,00H
    MOV BH,00H
    MOV BL,00H    ;set backgroundcolor to black
    INT 10H  
    
  RET
CLEAR_SCREEN ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;MOVE_BALL
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOVE_BALL PROC NEAR  
    
    ;X CHECK
    
    MOV AX,BALL_VELOCITY_X
    ADD BALL_X,AX
    
    MOV AX,WINDOW_BOUNDS 
    ADD AX,BOX_WIDTH
    CMP BALL_X,AX
    JL NEG_VELOCITY_X   
    
    ;check collision

     MOV AX,BALL_X
     ADD AX,BALL_SIZE
     CMP AX,0130H 
     JL  DO_NOTHING 
     MOV BX,BALL_Y
     CMP BX,PADDLE_RIGHT_Y
     JL  GAME_OVER
     MOV AX, PADDLE_RIGHT_Y
     ADD AX, PADDLE_HEIGHT
     CMP BALL_Y,AX
     JG  GAME_OVER
     
     COLLIDE:
        ;update score
        XOR AX,AX
        MOV AL,SCORE
        INC AL
        MOV SCORE , AL 
       CALL DISPLAY_LED
        
        CALL RANDOM_PADDLE_COLOR
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;
           
           MOV AL, SCORE
           CMP AL,WIN_POINT
           JGE GAME_WIN
           
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        JMP NEG_VELOCITY_X
        
 DO_NOTHING :    
        ; Y CHECK    
        
        MOV AX,BALL_VELOCITY_Y
        ADD BALL_Y,AX 
    
        CMP BALL_Y,01AH
        JL NEG_VELOCITY_Y
    
         CMP BALL_Y,0B4H
        JG NEG_VELOCITY_Y

RET

    GAME_OVER: 

        XOR AX,AX
        MOV SCORE , AL 
        ;JMP RESET_POS
        XOR AX,AX 
        INC AX
        MOV IS_OVER , AL
RET 
    GAME_WIN:
        CALL WIN_GAME

 
    RESET_POS :
        CALL RESET_BALL_POS 
        RET 
    NEG_VELOCITY_X : 
        NEG BALL_VELOCITY_X
        RET
  
    NEG_VELOCITY_Y :
        NEG BALL_VELOCITY_Y
        RET
     
MOVE_BALL ENDP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;RESET_BALL_POS
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RESET_BALL_POS PROC NEAR
     MOV AX,BALL_ORIGINAL_X
     MOV BALL_X,AX
     
     MOV AX,BALL_ORIGINAL_Y
     MOV BALL_Y,AX
       
     RET    
RESET_BALL_POS ENDP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;draw paddle
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DRAW_PADDLE PROC NEAR

			
        MOV CX,PADDLE_RIGHT_X ;set the initial column 
		MOV DX,PADDLE_RIGHT_Y ;set the initial line 
		
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH,0Ch     ;set the configuration to writing a pixel
			MOV AL,COLOR  ;choose white as initial color
			MOV BH,00h  ;set the page number 
			INT 10h     ;execute the configuration
			
			INC CX     
			MOV AX,CX          
			SUB AX,PADDLE_RIGHT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
			MOV CX,PADDLE_RIGHT_X 
			INC DX        
			
			MOV AX,DX              
			SUB AX,PADDLE_RIGHT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
						

RET
DRAW_PADDLE ENDP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;move paddle
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOVE_PADDLE PROC NEAR 
 
;right paddle 

;check if any key pressed
MOV AH,01H
INT 16H
JZ FINISH

;check which key pressed

MOV AH,00h
INT 16H

;if it is 'w' or 'W' move up
CMP AL,77H ;w
JE MOVE_RIGHT_PADDLE_UP
CMP AL,57H    ;W
JE MOVE_RIGHT_PADDLE_UP

;if it is 's' or 'S' move down
CMP AL,73H ;s
JE MOVE_RIGHT_PADDLE_DOWN
CMP AL,53H    ;S
JE MOVE_RIGHT_PADDLE_DOWN  

JMP FINISH  

MOVE_RIGHT_PADDLE_UP:
   MOV AX,PADDLE_VELOCITY
   SUB PADDLE_RIGHT_Y,AX
   
   MOV AX,WINDOW_BOUNDS_Y  
   CMP PADDLE_RIGHT_Y,AX 
   JL  FIX_PADDLE_RIGHT_TOP_POSITION
   JMP FINISH 
   
   FIX_PADDLE_RIGHT_TOP_POSITION:
        MOV PADDLE_RIGHT_Y,AX
        JMP FINISH
   
MOVE_RIGHT_PADDLE_DOWN:
   MOV AX,PADDLE_VELOCITY
   ADD PADDLE_RIGHT_Y,AX 
   
   MOV AX,WINDOW_HEIGHT
   SUB AX,WINDOW_BOUNDS
   SUB AX,PADDLE_HEIGHT
   CMP PADDLE_RIGHT_Y,AX 
   JG  FIX_PADDLE_RIGHT_BOTTOM_POSITION
   JMP FINISH 
   
   FIX_PADDLE_RIGHT_BOTTOM_POSITION:
        MOV PADDLE_RIGHT_Y,AX
        JMP FINISH
        
;left paddle 
FINISH : 
 
RET    
MOVE_PADDLE ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;draw box
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DRAW_BOX PROC NEAR 
    
        MOV CX,BOX_LEFT_X ;set the initial column
		MOV DX,BOX_LEFT_Y ;set the initial line 
		
		DRAW_BOX_LEFT_VERTICAL:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose white as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
			
			INC CX     
			MOV AX,CX          
			SUB AX,BOX_LEFT_X
			CMP AX,BOX_WIDTH
			JNG DRAW_BOX_LEFT_VERTICAL
			
			MOV CX,BOX_LEFT_X 
			INC DX        
			
			MOV AX,DX               
			SUB AX,BOX_LEFT_Y
			CMP AX,BOX_HEIGHT
			JNG DRAW_BOX_LEFT_VERTICAL    
			
		MOV CX,BOX_TOP_X ;set the initial column 
		MOV DX,BOX_TOP_Y ;set the initial line 
		
		DRAW_BOX_TOP_HORIZANTAL:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose white as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
			
			INC CX     
			MOV AX,CX          
			SUB AX,BOX_TOP_X
			CMP AX,BOX_WIDTH_HORIZANTAL
			JNG DRAW_BOX_TOP_HORIZANTAL
			
			MOV CX,BOX_TOP_X 
			INC DX        
			
			MOV AX,DX              
			SUB AX,BOX_TOP_Y
			CMP AX,BOX_HEIGHT_HORIZANTAL
			JNG DRAW_BOX_TOP_HORIZANTAL  
			
		MOV CX,BOX_BOTTOM_X ;set the initial column 
		MOV DX,BOX_BOTTOM_Y ;set the initial line 
		
		DRAW_BOX_BOTTOM_HORIZANTAL:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose white as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
			
			INC CX     
			MOV AX,CX         
			SUB AX,BOX_BOTTOM_X
			CMP AX,BOX_WIDTH_HORIZANTAL
			JNG DRAW_BOX_BOTTOM_HORIZANTAL
			
			MOV CX,BOX_BOTTOM_X 
			INC DX        
			
			MOV AX,DX           
			SUB AX,BOX_BOTTOM_Y
			CMP AX,BOX_HEIGHT_HORIZANTAL
			JNG DRAW_BOX_BOTTOM_HORIZANTAL             
             
RET             
DRAW_BOX ENDP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;draw SCORE
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

PRINT_SCORE PROC NEAR 
    
    XOR DX,DX
    XOR AX,AX
    MOV AL , SCORE
    mov bx, 10D 
	div bx
    add AX, 48 
    add DX, 48 
    XOR CX,CX
    MOV CL,AL ;remainder
    MOV CH,DL ;Q
    
    cmp cl,48
    jle  one_digit
    
    mov  dl, 20   ;Column
    mov  dh, 1    ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
    
    mov  al, CL
    mov  bl, 0Ch  ;Color is red
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h                 
       
 
    mov  dl, 30   ;Column
    mov  dh, 1   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 04h  ;SetCursorPosition
    int  10h
    
    mov  al, CH
    mov  bl, 0Ch  ;Color is red
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h   
    
ret    
one_digit: 

    mov  dl, 20   ;Column
    mov  dh, 1    ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
    
    mov  al, CH
    mov  bl, 0Ch  ;Color is red
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h           
    
RET
PRINT_SCORE ENDP  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;GAME OVER !!!
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
GAME_OVER_PAGE PROC NEAR 
                       
    mov AH, 00         ; set video mode 
    MOV AL,13H        ; graphic mode
    int 10h       
    
    MOV AH,00H
    MOV BH,01H
    MOV BL,00H    ;set backgroundcolor to black
    INT 10H 
        
    
   mov  dl, 15   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'G'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h    
    
    mov  dl, 16   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'A'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h  
    
    mov  dl, 17   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'M'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h 
    
    mov  dl, 18   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'E'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h
              
     mov  dl, 19   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'O'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h  
    
    mov  dl, 20   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'V'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h 
    
    mov  dl, 21   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'E'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h          
              
     mov  dl, 22   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'R'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h                    
    ; wait for any key press:
    mov ah, 0
    int 16h
    
    int 20 
   ; mov ax,3
   ; int 16
    ret 
    
    
    
    
    RET
GAME_OVER_PAGE ENDP  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;GENERATE RANDOM PADDLE COLOR !!!
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

RANDOM_PADDLE_COLOR PROC NEAR

random:        
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

   mov  ax, dx
   xor  dx, dx
   mov  cx, 010h    
   div  cx       ; dx has remainder from 0 to 15
   
   cmp dl, 00h
   je random
   
   mov color, dl
 
RET
RANDOM_PADDLE_COLOR ENDP  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;GENERATE RANDOM BALL INIT POINT !!!   
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

DISPLAY_LED PROC NEAR
   MOV AL , SCORE
   OUT 199 , AL     
 
RET
DISPLAY_LED ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
  
  ;WIN GAME !!!   
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

WIN_GAME PROC NEAR
        
 mov AH, 00         ; set video mode 
    MOV AL,13H        ; graphic mode
    int 10h       
    
    MOV AH,00H
    MOV BH,01H
    MOV BL,00H    ;set backgroundcolor to black
    INT 10H 
        
    
    mov  dl, 17   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'W'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h    
    
    mov  dl, 18   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'I'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h  
    
    mov  dl, 19   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'N'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h
    
    mov  dl, 20   ;Column
    mov  dh, 12   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
     
    mov  al,'!'
    mov  bl, 0Ch  ;Color is red
    mov  bh, 1h    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h 
    
    ; wait for any key press:
    mov ah, 0
    int 16h
    
    int 20 
 
RET
WIN_GAME ENDP 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE ENDS
END



