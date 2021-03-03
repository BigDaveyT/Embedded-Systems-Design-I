#include "io.h"
#include <stdio.h>
#include "system.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "altera_avalon_pio_regs.h"

// create standard embedded type definitions
typedef signed char    sint8;  // signed 8 bit values
typedef unsigned char  uint8;  // unsigned 8 bit values
typedef signed short   sint16; // signed 16 bit values
typedef unsigned short uint16; // unsigned 16 bit values
typedef signed long    sint32; // signed 32 bit values
typedef unsigned long  uint32; // unsigned 32 bit values
typedef float          real32; // 32 bit real values

// Pointers
volatile uint32 *PushbuttonsPtr = (uint32 *)PUSHBUTTONS_BASE; // points to PUSHBUTTONS_BASE
volatile uint32 *SwitchesPtr    = (uint32 *)SWITCHES_BASE;    // points to SWITCHES_BASE

uint32 *ServoPtr = (uint32 *)SERVO_CONTROLLER_0_BASE;         // points to SERVO_CONTROLLER_0_BASE

volatile int *HEX0 = (int *)HEX0_BASE; // points to HEX0_BASE
volatile int *HEX1 = (int *)HEX1_BASE; // points to HEX1_BASE
volatile int *HEX2 = (int *)HEX2_BASE; // points to HEX2_BASE
volatile int *HEX3 = (int *)HEX3_BASE; // points to HEX3_BASE
volatile int *HEX4 = (int *)HEX4_BASE; // points to HEX4_BASE
volatile int *HEX5 = (int *)HEX5_BASE; // points to HEX5_BASE

volatile uint32 switches    = 0; // variable to write and store switch values
volatile uint32 pushbuttons = 0; // variable to write and store pushbuttons values

unsigned char servoRegister0 = 45;  // default value of 45 degrees
unsigned char servoRegister1 = 135; // default value of 135 degrees

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
}; // End of Array


void pushbutton_isr(void *context)
/**************************************************************************/
/* Interrupt Service Routine                                              */
/* Checks the state of the switches stores the angle in either register,  */
/* depending on which button was pushed                                   */
/*                                                                        */
/**************************************************************************/
{
    pushbuttons = *(PushbuttonsPtr + 3); //read the pushbuttons value
    *(PushbuttonsPtr + 3) = pushbuttons;
    switches = *SwitchesPtr;  // read the value of switches

    if (pushbuttons == (pushbuttons & 0x8)) // (0b1000) key 3 was pressed to store lower angle
    {
        //store min angle
        servoRegister0 = switches;

        *HEX5 = hexNumbers[servoRegister0 / 10];
        *HEX4 = hexNumbers[servoRegister0 % 10];
    }

    else if (pushbuttons ==(pushbuttons & 0x4)) // (0b0100) key 2 was pressed to store upper angle
    {
        //store max angle
        servoRegister1 = switches;

        *HEX2 = hexNumbers[servoRegister1 / 100];
        *HEX1 = hexNumbers[(servoRegister1 - ((servoRegister1 / 100) * 100)) / 10];
        *HEX0 = hexNumbers[servoRegister1 % 10];
    }
}

void servo_registor_isr(void *context)
/**************************************************************/
/* Interrupt Service Routine                                  */
/* Loads the registers with counts so that the PWM crates the */
/* correct angle                                              */
/**************************************************************/
{
    // load the resgisters with the counts for the pwm so the angles are correct

    // Register0
    *(ServoPtr) = (555.55556 * servoRegister0) + 25000;

    //Register1
    *(ServoPtr + 1) = (555.55556 * servoRegister1) + 25000;
}

int main(void)
{
    //initial write to servo
    *HEX3 = 0x3F;
    
    // pushbuttons ISR
    alt_ic_isr_register(PUSHBUTTONS_IRQ_INTERRUPT_CONTROLLER_ID, PUSHBUTTONS_IRQ, pushbutton_isr, 0, 0);
    *(PushbuttonsPtr + 2) = 0xF; // 0b1111 mask the pushbuttons
    
    // Servo Controller ISR
    alt_ic_isr_register(SERVO_CONTROLLER_0_IRQ_INTERRUPT_CONTROLLER_ID, SERVO_CONTROLLER_0_IRQ, servo_registor_isr, 0, 0);
    
    // initial display of numbers to hex
    *HEX5 = hexNumbers[servoRegister0 / 10];
    *HEX4 = hexNumbers[servoRegister0 % 10];
    *HEX2 = hexNumbers[servoRegister1 / 100];
    *HEX1 = hexNumbers[(servoRegister1 - ((servoRegister1 / 100) * 100)) / 10];
    *HEX0 = hexNumbers[servoRegister1 % 10];
    while(1);
    return main();
}