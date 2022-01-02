; ******* Register definitions *******
		
RCC_AHB1ENR  EQU  0x40023830  ;Clock control for AHB1 peripherals (includes GPIO)

;GPIO-A control registers  -- for seven segment
GPIOA_MODER  EQU  0x40020000  ;set GPIO pin mode as Input/Output/Analog
GPIOA_IDR    EQU  0x40020010  ;GPIO pin input data
GPIOA_ODR    EQU  0x40020014  ;GPIO pin output data

;GPIO-B control registers  -- for data 
GPIOB_MODER  EQU  0x40020400  ;set GPIO pin mode as Input/Output/Analog
GPIOB_IDR    EQU  0x40020410  ;GPIO pin input data
GPIOB_ODR    EQU  0x40020414  ;GPIO pin output data

; **************************
    EXPORT SystemInit
	EXPORT __main

	AREA  MYCODE, CODE, READONLY
;===================================================================================================================================================	  
SystemInit FUNCTION

  ; Enable GPIO clock (enable all GPIOs)
  LDR    R1, =RCC_AHB1ENR  
  LDR    R0, [R1]    
  ORR.W  R0, #0x03         
  STR    R0, [R1]          
  
  ;set mode as input 
  LDR    R1,  =GPIOB_MODER
  LDR    R0,  [R1]
  MOV    R0, #0x00000000 ; set input to 0
  STR    R0, [R1]
  
  ; Set mode as output
  LDR    R1, =GPIOA_MODER  
  LDR    R0, [R1]      
  MOV    R0, #0x55555555   ;Mode bits set to '01' pin mode output
  STR    R0, [R1]
  

  ENDFUNC
;======================================================================================================================  
__main FUNCTION
	
data_arr DCB 4,3,0,3,2

  ;seven segment initial value is 0
  LDR    R1, =GPIOA_ODR
  MOV    R0,#0x0000
  STR    R0, [R1]
  ;load data arr
  LDR R6, =data_arr
  
LOOP
;-------------BUTTON 0------------------
  LDR    R2, =GPIOB_IDR
  LDR    R0, [R2]
  MOV    R1, R0
  
  ;BUTTON B0 AND PORT IS P10
  MOV    R4, #0xFBFF
  ORR    R0, R0, R4
  CMP    R0, R4
  BEQ    BUTTON_0 
;-------------BUTTON 1-------------------  

  LDR    R2, =GPIOB_IDR
  LDR    R0, [R2]
  MOV    R1, R0
  
  ;BUTTON B1 AND PORT IS P12
  MOV    R4, #0xEFFF
  ORR    R0, R0, R4
  CMP    R0, R4
  BEQ    BUTTON_1
;------------BUTTON 2----------------------  
  
  LDR    R2, =GPIOB_IDR
  LDR    R0, [R2]
  MOV    R1, R0
  
  ;BUTTON B2 AND PORT IS P13
  MOV    R4, #0xDFFF
  ORR    R0, R0, R4
  CMP    R0, R4
  BEQ    BUTTON_2
;-------------BUTTON 3----------------------
   
  LDR    R2, =GPIOB_IDR
  LDR    R0, [R2]
  MOV    R1, R0
  
  ;BUTTON B3 AND PORT IS P14
  MOV    R4, #0xBFFF
  ORR    R0, R0, R4
  CMP    R0, R4
  BEQ    BUTTON_3
;--------------BUTTON 4-----------------------

  LDR    R2, =GPIOB_IDR
  LDR    R0, [R2]
  MOV    R1, R0
  
  ;BUTTON B4 AND PORT IS P15 
  MOV    R4, #0x7FFF
  ORR    R0, R0, R4
  CMP    R0, R4
  BEQ    BUTTON_4
;--------------------------------------  

  B LOOP
;-----------------------------BUTTON LOGIC----------------------------------
 ; F(X)=X3 mod 100
;---------------------------------------------------------------------------

BUTTON_0
  LDRB   R3,[r6]
  BL     COMPUTE_POW
  MOV    R3, #100
  BL     COMPUTE_MOD
  MOV    R2, R5
  LDR    R1, =GPIOA_ODR
  BL     TO_DECIMAL  
  STR    R2, [R1]
  B 	 LOOP
;----------------------------

BUTTON_1
  LDRB   R3,[r6,#1] 
  BL     COMPUTE_POW
  MOV    R3, #100
  BL     COMPUTE_MOD
  MOV    R2, R5
  LDR    R1, =GPIOA_ODR
  BL     TO_DECIMAL  
  STR    R2, [R1]
  B 	 LOOP
;------------------------------  

BUTTON_2
  LDRB   R3,[r6,#2]
  BL     COMPUTE_POW
  MOV    R3, #100
  BL     COMPUTE_MOD
  MOV    R2, R5
  LDR    R1, =GPIOA_ODR
  BL     TO_DECIMAL  
  STR    R2, [R1]
  B 	 LOOP
;--------------------------------

BUTTON_3
  LDRB   R3,[r6,#3]
  BL     COMPUTE_POW
  MOV    R3, #100
  BL     COMPUTE_MOD
  MOV    R2, R5
  LDR    R1, =GPIOA_ODR
  BL     TO_DECIMAL  
  STR    R2, [R1]
  B 	 LOOP
;------------------------------------

BUTTON_4
  LDRB   R3,[r6,#4]  
  BL     COMPUTE_POW
  MOV    R3, #100
  BL     COMPUTE_MOD
  MOV    R2, R5 
  LDR    R1, =GPIOA_ODR
  BL     TO_DECIMAL
  STR    R2, [R1]
  B 	 LOOP

;--------------------------------HELPER FUNCTION----------------------------------------------------
  
;---------- POW FUN -------------------------------------  
COMPUTE_POW       
  MOV R4, #1
  MOV R5, #0
L1
  MUL R4, R4, R3
  ADD R5, R5, #1
  CMP R5, #3
  BEQ POW_END
  B L1  
POW_END
  MOV PC,R14
;--------------- MOD FUN ----------------------------------

COMPUTE_MOD   
  UDIV R5, R4, R3
  MUL R5, R5, R3
  SUB R5, R4, R5
  MOV PC,R14
;-------------- CONVERT TO DECIMAL-------------------------

TO_DECIMAL
  MOV R4, R2
  MOV R3, #10
  PUSH {R14}
  BL COMPUTE_MOD
  POP {R14}
  MOV R3, #10
  UDIV R3, R2, R3
  LSL R3,R3,#4
  MOV R2, #0x00000000
  ORR R2,R5
  ORR R2,R3
  MOV PC,R14

;--------------------END------------------------------------
 
  END
	  
 