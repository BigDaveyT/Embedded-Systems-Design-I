// NAME: David Tassoni
// Lab 3
// FILENAME: part_2.c

#include <stdbool.h>
#include "io.h"
#include <stdio.h>
#include "system.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "altera_avalon_timer_regs.h"
#include "altera_avalon_timer.h"

// create standard embedded type definitions
typedef signed char    sint8 ; // signed 8 bit values
typedef unsigned char  uint8 ; // unsigned 8 bit values
typedef signed short   sint16; // signed 16 bit values
typedef unsigned short uint16; // unsigned 16 bit values
typedef signed long    sint32; // signed 32 bit values
typedef unsigned long  uint32; // unsigned 32 bit values
typedef float          real32; // 32 bit real values


#define HEX_MAX 15
#define HEX_MIN 0

volatile uint8* Switches_Pointer    = (uint8*)SWITCHES_BASE;    // points to SWITCHES_BASE
uint8*   Hex_Pointer                = (uint8*)HEX0_BASE;        // points to HEX0_BASE
volatile uint8* Pushbuttons_Pointer = (uint8*)PUSHBUTTONS_BASE; // points to PUSHBUTTONS_BASE

uint8 pushbuttons;
uint8 count = 0; // initialize count to 0
uint8 switches;

uint8 hexNumbers[] = // array of hex numbers
{
	0x40, // 0
	0x79, // 1
	0x24, // 2
	0x30, // 3
	0x19, // 4
	0x12, // 5
	0x02, // 6
	0x78, // 7
	0x00, // 8
	0x18, // 9
	0x08, // A
	0x03, // b
	0x46, // c
	0x21, // d
	0x06, // E
	0x0E  // F
};  // End of Array

void pushbuttons_isr(void *context)
/**************************************************************************/
/* Interrupt Service Routine                                              */
/* Checks the state of the switches and increments or decrements the hex  */
/* display.                                                               */
/*                                                                        */
/**************************************************************************/
{
	switches = *Switches_Pointer; // read the switches state and store in the variable switches
	
	if((switches == 0b00000001)) // if SW0 high, check current value of count, reset if necessary, and increment the count
	{
		if(count == HEX_MAX)
		{
			count = HEX_MIN - 1;
		}
		count++;
	}
		
	else if((switches == 0b00000000)) // if SW0 low, check current value of count, reset if necessary, and decrement the count
	{
		if(count == HEX_MIN)
		{
			count = HEX_MAX + 1;
		}
		count--;
	}

	*(Pushbuttons_Pointer + 12) = 0;  // clear the interrupt
	*Hex_Pointer = hexNumbers[count]; // update the display
	
	return;
}

int main(void)
{
	count = 0; // ensure count starts at 0
	*Hex_Pointer = hexNumbers[count]; // update the display
	
	// enables NIOS II to accept a pushbutton interrupt
	alt_ic_isr_register(PUSHBUTTONS_IRQ_INTERRUPT_CONTROLLER_ID, PUSHBUTTONS_IRQ, pushbuttons_isr, 0, 0); 
	
	*(Pushbuttons_Pointer + 8) = 0b0010;
	
	return 0;
}
