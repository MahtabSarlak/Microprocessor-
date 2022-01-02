//================================ LIBRARIES ==========================================================
#include <stm32f4xx.h>
//================================ PARAMETERS =========================================================
void PORTA_CONF(void);
void PORTB_CONF(void);
void PORTC_CONF(void);
void LCD_init(void);
void LCD_command(unsigned char command);
void LCD_data(unsigned char data);
void delayMs(int n);
unsigned char * shift(unsigned char array[4],char input);
int input;

//================================ MAIN ==============================================================

int main(){
//================================ PARMETERS =========================================================
	unsigned char IdNumbers[]={'3','0','3','2'};
	unsigned char * nums = IdNumbers;
//================================ CONFIGURATIONS ====================================================
	PORTA_CONF();
	PORTB_CONF();
  PORTC_CONF();
	LCD_init();
//=====================================================================================================	
	while(1){
		LCD_command(0x80); //begin at first line 
		LCD_data(IdNumbers[0]);
		LCD_data(IdNumbers[1]);
		LCD_data(IdNumbers[2]);
		LCD_data(IdNumbers[3]);
		delayMs(50);
		
		
		GPIOB->ODR = 0XEFFF;
		input = GPIOB->IDR;
		switch(input){
			case 0xEEFF: // number 1
						nums = shift(nums,'1');break;
			case 0xEDFF: // number 2
						nums = shift(nums,'2');break;
			case 0xEBFF: // number 3
						nums = shift(nums,'3');break;
		}
		
		GPIOB->ODR = 0XDFFF;
		input = GPIOB->IDR;
		switch(input){
			case 0xDEFF: // number 4
						  nums = shift(nums,'4');break;
			case 0xDDFF: // number 5
						  nums = shift(nums,'5');break;
			case 0xDBFF: // number 6
						  nums = shift(nums,'6');break;
		}
		
		GPIOB->ODR = 0XBFFF;
		input = GPIOB->IDR;
		switch(input){
			case 0xBEFF: // number 7
						  nums = shift(nums,'7');break;
			case 0xBDFF: // number 8
						  nums = shift(nums,'8');break;
			case 0xBBFF: // number 9
			  		  nums = shift(nums,'9');break;
		}
		
		GPIOB->ODR = 0X7FFF;
		input = GPIOB->IDR;
		switch(input){
			case 0x7DFF: // number 0
			  		  nums = shift(nums,'0');break;
		}
		
	}
}

//================================ PORT CONFIG ==================================================
void PORTA_CONF(){
	//clock for GPIOA 
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

void PORTC_CONF(){
	//clock for GPIOC 
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
	//MODER PORT C 
	GPIOC->MODER = 0x55555555;
}
//============================= LCD FUNCTIONS ====================================================
void LCD_init(){
	delayMs(30);
	LCD_command(0x30);
	delayMs(10);
	LCD_command(0x30);
	delayMs(1);
	LCD_command(0x30);
	LCD_command(0x38); //8 bit data - 2 line - 5*7 font 
	LCD_command(0x06); //move cursor right 
	LCD_command(0x01); //clear 
	LCD_command(0x0f); //turn on display - cursor blinking 
}

void LCD_command(unsigned char command){
	GPIOC->ODR = 0x0; //rs=0 rw=0
	GPIOA->ODR = command;
	GPIOC->ODR = 0x4; //pulse enable
	delayMs(0);
	GPIOC->ODR = 0x0; 
	if(command<4)
		delayMs(4);
	else
		delayMs(1);
}

void LCD_data(unsigned char data){
		GPIOC->ODR = 0x1; //rs=1
		GPIOA->ODR = data; //rw=0
		GPIOC->ODR = 0x5; 
		delayMs(0);
		GPIOC->ODR = 0x1;
	  delayMs(1);
}

//================================ HELPER FUNCTIONS ==================================================
unsigned char * shift(unsigned char arrays[4],char input){
	arrays[0]=arrays[1];
	arrays[1]=arrays[2];
	arrays[2]=arrays[3];
	arrays[3]= input;
	return arrays;
}

// generate delay
void delayMs(int ms){
	int i,j;
	for(i=0;i<ms;i++){
		for(j=0;j<20000;j++){
					__NOP();
		}
	}
}
//================================ END ================================================================