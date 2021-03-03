-------------------------------------------------------------------------
-- Name:        David Tassoni
-- Course:      CPET 561-01
-- Assignement: Lab 4 
-- File:        Lab_4_RAM.vhd
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;      
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all; 

Entity Lab_4_RAM is 
  Port (
  
        clk               : in  std_logic;
        write             : in  std_logic;
        reset_n           : in  std_logic;
        address           : in  std_logic_vector(1 downto 0);
        data_in           : in  std_logic_vector(31 downto 0);
        data_out          : out std_logic_vector(31 downto 0)    
  );
  
End Lab_4_RAM;

Architecture beh of Lab_4_RAM is

-- Signal Declarations

Type ram_type is array (1 downto 0) of std_logic_vector(31 downto 0);

Signal Registers : ram_type := (others => (others => '0'));
Constant address_0 :std_logic_vector(1 downto 0):= "00";
Constant address_1 :std_logic_vector(1 downto 0):= "01";

Begin 

Process(clk,reset_n, write)
 Begin
   IF (reset_n = '0') Then 
     Registers(to_integer(unsigned(address_0))) <= x"0000C350"; --50000   limit for sweep left 
     Registers(to_integer(unsigned(address_1))) <= x"000186A0"; --100000  limit for sweep right
   Elsif (rising_edge(clk)) then
   
    if (write = '1') then    
      Registers(to_integer(unsigned(address))) <= data_in; 
    end if;
      data_out <= Registers(to_integer(unsigned(address))); 
   end if;    
  End Process;
End beh; 