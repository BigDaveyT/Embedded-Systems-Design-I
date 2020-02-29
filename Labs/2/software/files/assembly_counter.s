# -------------------------------------------------------------------------
#
# -------------------------------------------------------------------------
 
.data
.text
 
# define a macro to move a 32 bit address to a register
 
.macro MOVIA reg, addr
  movhi \reg, %hi(\addr)
  ori \reg, \reg, %lo(\addr)
.endm
 
# define constants
.equ Switches, 0x11020     /* find the base address of Switches in the system.h file    */
.equ HEX0, 0x11000         /* find the base address of HEX0 in the system.h file        */
.equ Pushbuttons, 0x11010  /* find the base address of Pushbuttons in the system.h file */
.equ lowNum, 64            /* set lowNum  as 64 (0 for digits)                          */
.equ highNum, 24           /* set highNum as 24 (9 for digits)                          */
						   
# define main program      
.global main               
						   
# notes:                   
# r9  = load 'SSDconstants'
# r10 = load 'Switches'    
# r11 = load 'Pushbuttons' 
						   
main:                      
   movia r2,  Switches      /* load r2 with 'Switches' address                     */
   movia r3,  HEX0          /* load r3 with 'HEX0' address		                   */
   movia r4,  Pushbuttons   /* load r4 with 'Pushbuttons' address                  */
   movia r5,  SSDconstants  /* load r5 with 'SSDconstants' array                   */
   movia r6,  1             /* load r6 with 1 for high                             */
   movia r7,  15            /* load r7 with 0b1101 for high (active low pushbutton */
   movia r8,  lowNum        /* load r8 with 'lowNum' constant                      */
   movia r12, highNum       /* load r12 with 'highNum' constant                    */
						   
loop:                      
   ldbio r9, 0(r5)         /* load 'SSDconstants' into r9           */
   stbio r9, 0(r3)         /* store r9 into 'HEX0'                  */
   ldbio r10, 0(r2)        /* load 'Switches' into r10              */
   andi r10, r10, 1        /* bitmask SW0 (0000000#)                */
   ldbio r11, 0(r4)        /* load 'Pushbuttons' into r11           */
   ori r11, r11, 13        /* bitmask KEY1 (11#1)                   */
   beq r11, r7, direction  /* branch to 'direction' if KEY1 is not pressed */
   br loop                 /* go back to beginning of 'loop'        */
						   
direction:                 
   beq r10, r0, decrement  /* branch to 'decrement' if SW0 is low   */
   beq r10, r6, increment  /* branch to 'increment' if SW0 is high  */
						   
decrement:                 
   beq r9, r8, errorCheck  /* branch to 'errorCheck' if SSD is on 0 */
   subi r5, r5, 4          /* decrement array                       */
   br loop                 /* go back to beginning of 'loop'        */
   
increment:
   beq r9, r12, errorCheck /* branch to 'errorCheck' if SSD is on 9 */
   addi r5, r5, 4          /* increment array */
   br loop                 /* go back to beginning of 'loop' */
   
errorCheck:
   br loop                 /* go back to beginning of 'loop' */
 
SSDconstants:
   .word 64, 121, 36, 48, 25, 18, 2, 120, 0, 24 /* from zero to nine */
