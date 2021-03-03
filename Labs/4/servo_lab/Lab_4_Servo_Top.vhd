-------------------------------------------------------------------------
-- Name:        David Tassoni
-- Course:      CPET 561-01
-- Assignement: Lab 4 
-- File:        Lab_4_Servo_Top.vhd
--
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY Lab_4_Servo_Top IS
  Port (
      ----- CLOCK -----
      CLOCK_50 : in std_logic;
      
      ----- KEY -----
      KEY : in std_logic_vector(3 downto 0);  
      
      ----- LED -----
      LEDR : out  std_logic_vector(9 downto 0);
      
      ----- GPIO_0, GPIO_0 connect to GPIO Default -----
      GPIO_0 : inout  std_logic_vector(35 downto 0)  
  );
End ENTITY Lab_4_Servo_Top;

ARCHITECTURE arch of Lab_4_Servo_Top IS
  
  --Signal Declarations
  Signal Reset_n    : std_logic;
  Signal Key0_D1    : std_logic;
  Signal Key0_D2    : std_logic;
  Signal Key0_D3    : std_logic;
  Signal Write_En   : std_logic := '1'; --Continuous sweep of servo (always acknowledge interrupts)
  Signal Address_0  : std_logic_vector(1  downto 0) := "00"; --Signal to access register 0
  Signal Write_Data : std_logic_vector(31 downto 0) := x"0000C350"; --50,000, the Min Angle Value

  --Component Declaration for Servo Controller
  Component Lab_4_Servo_Controller IS
    Port (
          clk       : IN  STD_LOGIC;
          reset_n   : IN  STD_LOGIC;
          write     : IN  STD_LOGIC;
          writedata : IN  STD_LOGIC_VECTOR(31 downto 0);
          address   : IN  STD_LOGIC_VECTOR( 1 downto 0);
          wave_out  : OUT STD_LOGIC;
          irq       : OUT STD_LOGIC  
    );
  End Component Lab_4_Servo_Controller;  
  
BEGIN
  ----- Syncronize the reset
  synchReset_proc : process (CLOCK_50) begin
    if (rising_edge(CLOCK_50)) then
      Key0_D1 <= KEY(0);
      Key0_D2 <= Key0_D1;
      Key0_D3 <= Key0_D2;
    end if;
  end process synchReset_proc;
  Reset_n <= Key0_D3;

  --Port Map of Servo Controller
  Servo_Controller: Lab_4_Servo_Controller
  Port Map (
            clk       => CLOCK_50, 
            reset_n   => Reset_n,
            write     => Write_En, 
            writedata => Write_Data, 
            address   => Address_0,
            wave_out  => GPIO_0(10),
            irq       => LEDR(9)
  );
  

End Architecture arch;