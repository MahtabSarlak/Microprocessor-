//============================ LIBRARIES ============================================================
#include  <stm32f4xx.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
//============================= PARAMETERS ===========================================================
void PORTA_CONF(void);
void PORTB_CONF(void);
void delayMs( );
void sevSegDisplay();
int * shift(int array[4],int input);
//============================== MAIN =================================================================
int main(){
//parameter init
	unsigned char sevenSegNums[]=
	{0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f};
	unsigned char * sevenSegNum = sevenSegNums;
	int idNumbers[4] = {3,0,3,2};
	int * nums = idNumbers;
	int input;

// port configuration 	
	PORTA_CONF();
	PORTB_CONF();
	
	GPIOB->ODR = 0XEFFF;
	while(1){
		 sevSegDisplay(nums , sevenSegNum);
		 GPIOB->ODR = 0XEFFF;
		int input = GPIOB->IDR;
		switch(input){
			case 0xEEFF: // number 1
				  shift(nums,1);break;
			case 0xEDFF:  // number 2
		     	shift(nums,2);break;
			case 0xEBFF:  // number 3
			    shift(nums,3);break;
		}
		GPIOB->ODR = 0XDFFF;
		input = GPIOB->IDR;
		switch(input){
			case 0xDEFF:  // number 4
					shift(nums,4);break;
			case 0xDDFF:  // number 5
					shift(nums,5);break;
			case 0xDBFF:  // number 6
					shift(nums,6);break;
		}
		GPIOB->ODR = 0XBFFF;
		input = GPIOB->IDR;
		switch(input){
			case 0xBEFF:  // number 7
					shift(nums,7);break;
			case 0xBDFF:  // number 8
					shift(nums,8);break;
			case 0xBBFF:  // number 9
			  	shift(nums,9);break;
		}
		GPIOB->ODR = 0X7FFF;
		input = GPIOB->IDR;
		switch(input){
			case 0x7DFF: 
			  	shift(nums,0);break;
		}
	}
}

//================================= PORT CONFIGURATION =======================================================
		
void PORTA_CONF(){
//clock for GPIOA (ageh ghablesh kasi enable shode basheh nare) 
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
//MODER PORT A 
	GPIOA->MODER = 0x55555555;
}
void PORTB_CONF(){
//clock for GPIOB 
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;
//MODER PORT B
	GPIOB->MODER = 0x55000000;
}

//========================= HELPER FUNCTIONS ===============================================================

//display numbers on seven segment
void sevSegDisplay(int numbers[4] , unsigned char sevenSegNum[]){
        int delay = 8;
        int data;
        int output;

//	First Number
				data = sevenSegNum[numbers[0]];
        GPIOA->ODR = 0x0000;
        delayMs(1);
        output = 0x0800;
        output += data;
        GPIOA->ODR = output;
        delayMs(delay);

//	Second Number
				data = sevenSegNum[numbers[1]];
        GPIOA->ODR = 0x0000;
        delayMs(1);
        output = 0x0400;
        output += data;
        GPIOA->ODR = output;
        delayMs(delay);

//	Third Number
				data = sevenSegNum[numbers[2]];
        GPIOA->ODR = 0x0000;
        delayMs(1);
        output = 0x0200;
        output += data;
        GPIOA->ODR = output;
        delayMs(delay);
				
//  Fourth Number
				data = sevenSegNum[numbers[3]];
        GPIOA->ODR = 0x0000;
        delayMs(1);
        output = 0x0100;
        output += data;
        GPIOA->ODR = output;
        delayMs(delay);
    }

// generate delay
void delayMs(long ms)
{
	int i , j;
  for(i = 0 ; i < ms; i++){
		for (j = 0; j < 20000; j++) {
		__NOP();  
		}
	}
}

// shift numbers 

int * shift(int array[4],int input){
	array[0] = array[1];
	array[1] = array[2];
	array[2] = array[3];
	array[3] = input;
	return array;
}
//========================= END =============================================================================