#include "io.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "system.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "altera_nios2_gen2_irq.h"      // for standard embedded types
#include <math.h>

// create standard embedded type definitions
typedef signed char    sint8;  // signed 8 bit values
typedef unsigned char  uint8;  // unsigned 8 bit values
typedef signed short   sint16; // signed 16 bit values
typedef unsigned short uint16; // unsigned 16 bit values
typedef signed long    sint32; // signed 32 bit values
typedef unsigned long  uint32; // unsigned 32 bit values
typedef float          real32; // 32 bit real values

volatile int *Key1Ptr = (int *)PUSHBUTTONS_BASE;   // Pointer to the base address of the PUSHBUTTONS (for KEY1)
volatile int *LEDPtr  = (int *)LEDS_BASE;          // Pointer to the bass address of the LEDs
uint8  *RAM8bitPtr  = (uint8  *)INFERRED_RAM_BE_BASE; // Pointer to the base address of the RAM
uint16 *RAM16bitPtr = (uint16 *)INFERRED_RAM_BE_BASE; // Pointer to the base address of the RAM
uint32 *RAM32bitPtr = (uint32 *)INFERRED_RAM_BE_BASE; // Pointer to the base address of the RAM
uint32 *JtagUartPtr = (uint32 *)JTAG_UART_0_BASE;  // Pointer to the base address of the JTAG UART

int RAM8bit(uint8 *startaddress, unsigned int numBytestoTest, uint8 testData)
{
    for (int i = 0; i < numBytestoTest; i++)
    {
        // This for loop will write the data to the RAM
        *(startaddress + i) = testData;
    }

    for (int i = 0; i < numBytestoTest; i++)
    {
        // This for loop error checks
        if (testData != *(startaddress + i))
        {
            // checks for error (since the test data is not equal
            // prints the address and test data according to the lab sheet
            printf("\n\nERROR: Address: 0x%u Read: 0x%u Expected: 0x%u", i, *(startaddress + i), testData);
            *LEDPtr = 0xFF; // turn on LEDS to show there was an error
        }
        
        else
        {
            *LEDPtr = 0; // turn off LEDS since no error
        }
    }
    return 1;
}

int RAM16bit(uint16 *startaddress, unsigned int numBytestoTest, uint16 testData)
{
    for (int i = 0; i < numBytestoTest; i++)
    {
        // This for loop will write the data to the RAM
        *(startaddress + i) = testData;
    }

    for (int i = 0; i < numBytestoTest; i++)
    {
        // This for loop error checks
        if (testData != *(startaddress + i))
        {
            // checks for error (since the test data is not equal
            // prints the address and test data according to the lab sheet
            printf("\n\nERROR: Address: 0x%u Read: 0x%u Expected: 0x%u", i, *(startaddress + i), testData);
            *LEDPtr = 0xFF; // turn on LEDS to show there was an error
        }
        else
        {
            *LEDPtr = 0; // turn off LEDS since no error
        }
    }
    return 1;
}

int RAM32bit(uint32 *startaddress, unsigned int numBytestoTest, uint32 testData)
{
    for (int i = 0; i < numBytestoTest; i++)
    {
        // This for loop will write the data to the RAM
        *(startaddress + i) = testData;
    }

    for (int i = 0; i < numBytestoTest;)
    {
        // This for loop error checks
        if (testData != *(startaddress + i))
        {
            // checks for error (since the test data is not equal
            // prints the address and test data according to the lab sheet
            printf("\n\nERROR: Address: 0x%u Read: 0x%u Expected: 0x%u", i, *(startaddress + i), testData);
            *LEDPtr = 0xFF; // turn on LEDS to show there was an error
        }
        else
        {
            *LEDPtr = 0; // turn off LEDS since no error
        }
        i++;
    }
    return 1;
}


void Pushbutton_isr (void* context)
{
    // ISR to stop the program when the pushbutton is pressed
    *(Key1Ptr + 3) = 0x02; // 0b0010 (KEY 1) checks to see if KEY1 pressed
    
    while(1)
    {
        *LEDPtr =  0xA8;
        printf((uint8*)"RAM TEST DONE", 13); // message printed to JTAG UART upon completion
    }
}

int main(void)
{
    // main loop
    *LEDPtr = 0; // write the initial value to LEDs (all off)
    
    // TEST A
    RAM8bit (RAM8bitPtr,  4096, 0x00);       // 0x00 given as test data
    
    // TEST B
    RAM16bit(RAM16bitPtr, 4096, 0x1234);     // 0x1234 given as test data
    
    // TEST C
    RAM32bit(RAM32bitPtr, 4096, 0xABCDEF90); // 0xABCDEF90 given as test data
    
    *(Key1Ptr + 2) = 0xF; // 0b1111 (all buttons pushed)
    
    alt_ic_isr_register(PUSHBUTTONS_IRQ_INTERRUPT_CONTROLLER_ID, PUSHBUTTONS_IRQ, Pushbutton_isr, 0, 0);
    
    while(1)
    {
    };
    
    return (0);
}
