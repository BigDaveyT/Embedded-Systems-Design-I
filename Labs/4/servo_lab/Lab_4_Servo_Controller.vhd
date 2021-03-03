-------------------------------------------------------------------------
-- Name:        David Tassoni
-- Course:      CPET 561-01
-- Assignement: Lab 4 
-- File:        Lab_4_Servo_Controller.vhd
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY Lab_4_Servo_Controller is
  Port (
        clk         : IN  STD_LOGIC;
        reset_n     : IN  STD_LOGIC;
        write       : IN  STD_LOGIC;
        writedata   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        address     : IN  STD_LOGIC_VECTOR(1 downto 0);
        wave_out    : OUT STD_LOGIC;
        irq         : OUT STD_LOGIC  
        );
End Entity Lab_4_Servo_Controller;

Architecture beh of Lab_4_Servo_Controller is

 --Signal and Constant Decalarations 
 Constant Default_Angle_Min       : unsigned(31 DOWNTO 0) := x"0000C350"; -- 45  degrees (50,000)
 Constant Default_Angle_Max       : unsigned(31 DOWNTO 0) := x"000186A0"; -- 135 degrees (100,000)

 Constant Max_Count               : unsigned(31 DOWNTO 0) := x"000F4240"; -- 20ms/ 20ns = 1,000,000

 Signal Period_Count              : unsigned(31 DOWNTO 0) := (others => '0');
 Signal Up_Angle_Count            : unsigned(31 DOWNTO 0) := x"0000C350"; --Starting point (50,000)
 Signal Down_Angle_Count          : unsigned(31 DOWNTO 0) := x"000186A0"; --Starting point (100,000)
 Signal Current_Lower_Angle_Limit : unsigned(31 DOWNTO 0) := x"0000C350"; --50,000
 Signal Current_Upper_Angle_Limit : unsigned(31 DOWNTO 0) := x"000186A0"; --100,000
 Signal RAM_Angle_Limit           : unsigned(31 downto 0);
 
 
 Component Lab_4_RAM IS
   Port (  
        clk      : in std_logic;
        write    : in std_logic;
        reset_n  : in std_logic;
        address  : in std_logic_vector(1 downto 0);
        data_in  : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)    
   );
 End Component Lab_4_RAM;
 
 
 TYPE state_type IS (SWEEP_RIGHT, INT_RIGHT, SWEEP_LEFT, INT_LEFT); -- state names from lab handout
 Signal current_state, next_state: state_type;
 
 Begin
 
 -- Port Map of RAM 
   Servo_Reg: Lab_4_RAM
   Port Map ( 
             clk                => clk, 
             write              => write,
             reset_n            => reset_n,
             address            => address,
             data_in            => writedata,
             unsigned(data_out) => RAM_Angle_Limit
             
   );
   
  -- 20ms Max Counter process
    Process(clk, reset_n)
        Begin
            If (reset_n = '0') Then 
                Period_Count <= (others => '0');
            Elsif (rising_edge(clk)) Then
                If (Period_Count = Max_Count) Then 
                    Period_Count <= (others => '0');
                Else 
                    Period_Count <= Period_Count + 1;
                End If;
            End if; 
    End Process; 
    
   -- Max Angle Counter process
   Process(clk, reset_n, current_state, address, Period_Count, Up_Angle_Count, Down_Angle_Count, Current_Upper_Angle_Limit, 
           Current_Lower_Angle_Limit)
     Begin
       If (reset_n = '0') Then 
          Up_Angle_Count   <= Default_Angle_Min; -- reset to the default value
          Down_Angle_Count <= Default_Angle_Max; -- reset to the default value
          
       Elsif (rising_edge(clk)) Then
       
        -- Sets width of pulse in the SWEEP_RIGHT state
        -- increments when the period count is less than or equal to the max up angle count
         If (current_state = SWEEP_RIGHT) Then
            If (Period_Count <= Up_Angle_Count) Then
                wave_out <= '1';
            Elsif (Period_Count > Up_Angle_Count) Then
                wave_out <= '0';
            End if;
           
        -- Sets width of pulse in SWEEP_LEFT state
        -- increments when the period count is less than or equal to the max down angle count
         Elsif (current_state = SWEEP_LEFT) Then
         
          if (Period_Count <= Down_Angle_Count) Then
            wave_out <= '1';
          Elsif (Period_Count > Down_Angle_Count) Then
            wave_out <= '0';
          End if;
        
        --Update of Current_Lower_Angle_Limit from RAM in the INT_RIGHT state
         Elsif (current_state = INT_RIGHT) Then
         
            if (address = "00" ) Then 
               Current_Lower_Angle_Limit <= RAM_Angle_Limit;
            Else 
              Null;               
            End if;
            
            --Update of Down_Angle_Count w/ current Up_Angle_Count
            Down_Angle_Count <= Up_Angle_Count; 
        
        --Update of Current_Upper_Angle_Limit from RAM in the INT_LEFT state
         Elsif (current_state = INT_LEFT) Then 
         
            if (address = "01" ) Then 
              Current_Upper_Angle_Limit <= RAM_Angle_Limit;
            Else 
              NULL;
            End if;
            
            -- Update of Up_Angle_Count w/ current Down_Angle_Count
            Up_Angle_Count <= Down_Angle_Count;
            
         End if;
         
         -- Increments/Decrements the angle count at the end of 20 ms period
          If (Period_Count = Max_Count) Then
            if (Up_Angle_Count < Current_Upper_Angle_Limit) Then
              Up_Angle_Count <= Up_Angle_Count + x"00001388"; -- increment by step size of 5000
                  
            Elsif (Down_Angle_Count > Current_Lower_Angle_Limit) Then
              Down_Angle_Count <= Down_Angle_Count - x"00001388"; --decrement by step size of 5000
            End if; 
          End If; 
       End if; 
    End Process; 
        
  -- State Machine process
  Process (clk, reset_n)
    Begin
      If (reset_n = '0') Then 
        current_state <= SWEEP_RIGHT; --Default state SWEEP_RIGHT 
      Elsif (rising_edge(clk)) Then 
        current_state <= next_state;  --Go to the next state 
      End If; 
  End Process;
  
  Process (current_state, write, Up_Angle_Count, Down_Angle_Count, address)
    Begin 
    Case (current_state) IS 
    
      When SWEEP_RIGHT => 
      
      irq <= '0'; -- Set the irq flag low (0) since Angle Limit is not reached
      
        If (address = "01") Then -- If register 1 is accessed
          If (Up_Angle_Count = RAM_Angle_Limit) Then -- If the Up_Angle_Count = RAM_Angle_Limit Then
            irq <= '1';                              -- set irq flag to 1 
            next_state <= INT_RIGHT;                 -- go to INT_RIGHT state
          Else                                        
            next_state <= SWEEP_RIGHT;               -- Else stay in SWEEP_RIGHT state
          End if;          
        Else -- If register 1 is not accessed
          If (Up_Angle_Count = Current_Upper_Angle_Limit) Then  -- If Up_Angle_Count = Current_Upper_Angle_Limit Then
            irq <= '1';                 -- set irq to 1 
            next_state <= INT_RIGHT;    -- go to INT_RIGHT state
          Else                          
            next_state <= SWEEP_RIGHT;  -- Else stay in SWEEP_RIGHT state
          End if;                                                   
        End If; 
        
      When INT_RIGHT =>
        If (write = '1') Then        -- If write = '1' Then 
          irq <= '0';                -- clear the irq flag
          next_state <= SWEEP_LEFT;  -- go to SWEEP_LEFT state
        Else                          
          next_state <= INT_RIGHT;   -- Else stay in INT_RIGHT state
        End If;
          
      When SWEEP_LEFT => 
      If (address = "00") Then  -- If register 0 is accessed
        If (Down_Angle_Count = RAM_Angle_Limit) Then -- If Down_Angle_Count = RAM_Angle_Limit Then
          irq <= '1';                                -- set irq flag to 1 
          next_state <= INT_LEFT;                    -- go to INT_LEFT state
        Else                                         
          next_state <= SWEEP_LEFT;                  -- Else stay in SWEEP_LEFT state
        End If;                                                     
      Else -- If register 0 is not accessed
        If (Down_Angle_Count = Current_Lower_Angle_Limit) Then  -- If Down_Angle_Count = Current_Lower_Angle_Limit Then
          irq <= '1';                                           -- set irq flag to 1 
          next_state <= INT_LEFT;                               -- go to INT_LEFT state
        Else                                                    
          next_state <= SWEEP_LEFT;                             -- Else stay in SWEEP_LEFT state
        End If;                                                     
      End If; 

      When INT_LEFT =>                                                
        If (write = '1') Then -- If write = '1'
          irq <= '0';                -- irq flag is cleared
          next_state <= SWEEP_RIGHT; -- go to SWEEP_RIGHT state
        Else                        
          next_state <= INT_LEFT;    -- Else stay in INT_LEFT state
        End If;                                                    
                                                                   
      When Others =>                                               --Safty Net Clause 
        next_state <= SWEEP_RIGHT; 
    End Case;
  End Process;
End beh; 
