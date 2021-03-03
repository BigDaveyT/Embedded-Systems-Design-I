-------------------------------------------------------------------------
-- Name:        David Tassoni
-- Course:      CPET 561-01
-- Assignment:  Lab 5 
-- File:        Lab_5_Servo_Controller.vhd
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY Lab_4_Servo_Controller is
    Port
    (
        clk         : IN  STD_LOGIC;
        reset_n     : IN  STD_LOGIC;
        write       : IN  STD_LOGIC;
        writedata   : IN  UNSIGNED(31 DOWNTO 0);
        address     : IN  STD_LOGIC_VECTOR(1 downto 0);
        wave_out    : OUT STD_LOGIC;
        irq         : OUT STD_LOGIC := '0'
    );
End Entity Lab_4_Servo_Controller;

Architecture beh of Lab_4_Servo_Controller is

    -- signal and constant Decalarations  --
    constant Default_Angle_Min : unsigned(31 DOWNTO 0) := x"0000C350"; -- 45  degrees (50,000)
    constant Default_Angle_Max : unsigned(31 DOWNTO 0) := x"000186A0"; -- 135 degrees (100,000)
    constant max_count   : unsigned(31 DOWNTO 0) := x"000F4240"; -- 20ms/ 20ns = 1,000,000
    constant address_0 : std_logic_vector(1 downto 0):= "00";
    constant address_1 : std_logic_vector(1 downto 0):= "01";
    
    signal   period_count       : unsigned(31 DOWNTO 0) := (others => '0');
    signal   up_angle_count          : unsigned(31 DOWNTO 0) := x"0000C350"; --Default starting point (50,000)
    signal   down_angle_count        : unsigned(31 DOWNTO 0) := x"000186A0"; --Default starting point (100,000)
    
    signal   current_lower_angle_limit    : unsigned(31 DOWNTO 0) := x"0000C350"; --50,000
    signal   current_upper_angle_limit    : unsigned(31 DOWNTO 0) := x"000186A0"; --100,000
    
    signal   RAM_angle_limit  : unsigned(31 downto 0);
    
    type     ram_type is array (1 downto 0) of unsigned(31 downto 0);
    signal   Registers : ram_type := (others => (others => '0'));
    
    TYPE     state_type IS (SWEEP_RIGHT, WAIT_1, SWEEP_LEFT, WAIT_2);
    signal   current_state, next_state: state_type;

    Begin
        -- RAM Block --
        Process(clk,reset_n, write) 
        Begin
            IF (reset_n = '0') Then 
                Registers(to_integer(unsigned(address_0))) <= x"0000C350"; --50000   limit for end of sweep left 
                Registers(to_integer(unsigned(address_1))) <= x"000186A0"; --100000  limit for end of sweep right
            Elsif (rising_edge(clk)) then
                if (write = '1') then    
                    Registers(to_integer(unsigned(address))) <= writedata; 
                end if;
                
            RAM_angle_limit <= Registers(to_integer(unsigned(address))); 
            end if;    
        End Process;
  
        --20ms Max Counter 
        Process(clk, reset_n)
        Begin
            If (reset_n = '0') Then 
                period_count <= (others => '0');
            Elsif (rising_edge(clk)) Then
                If (period_count = max_count) Then 
                    period_count <= (others => '0');
                Else 
                    period_count <= period_count + 1;
                End If;
            End if; 
        End Process; 
    
        -- Max Angle Counter process
        Process(clk, reset_n, current_state, address, period_count, up_angle_count, down_angle_count, current_upper_angle_limit, 
                current_lower_angle_limit)
        Begin
            If (reset_n = '0') Then 
                up_angle_count   <= Default_Angle_Min;
                down_angle_count <= Default_Angle_Max;
            Elsif (rising_edge(clk)) Then
                -- Sets width of pulse in SWEEP_RIGHT state--
                If (current_state = SWEEP_RIGHT) Then
                    If (period_count <= up_angle_count) Then
                        wave_out <= '1';
                    Elsif (period_count > up_angle_count) Then
                        wave_out <= '0';
                    End if;
                    
        ----------------------------------------------

                --Sets width of pulse in SWEEP_LEFT state----
                Elsif (current_state = SWEEP_LEFT) Then
                    if (period_count <= down_angle_count) Then
                        wave_out <= '1';
                    Elsif (period_count > down_angle_count) Then
                        wave_out <= '0';
                    End if;
        ----------------------------------------------
        
                --Update of current_lower_angle_limit from RAM in WAIT_1 state----
                Elsif (current_state = WAIT_1) Then
                    if (address = "00" ) Then 
                        current_lower_angle_limit <= RAM_angle_limit;
                    Else 
                        Null;               
                    End if;
            
                down_angle_count <= up_angle_count; --Update of down_angle_count w/ current up_angle_count
        -------------------------------------------------------------------
        
                --Update of current_upper_angle_limit from RAM in WAIT_2 state-----
                Elsif (current_state = WAIT_2) Then 
                    if (address = "01" ) Then 
                        current_upper_angle_limit <= RAM_angle_limit;
                    Else 
                        NULL;
                    End if;
                    
                up_angle_count <= down_angle_count; --Update of up_angle_count w/ current down_angle_count
            
                End if;
         -------------------------------------------------------------------
         
            --IF Then Else Statement - Increments or Decrements the angle count at the end of 20 ms---- 
            If (period_count = max_count) Then
                if (up_angle_count < current_upper_angle_limit) Then
                    up_angle_count <= up_angle_count + x"00001388"; --step size of 5000 (increment)
                Elsif (down_angle_count > current_lower_angle_limit) Then
                    down_angle_count <= down_angle_count - x"00001388"; --step size of 5000 (decrement)
                End if; 
            End If; 
         --------------------------------------------------------------------------------------- 
        End if; 
    End Process; 
        
    --State Machine 
    Process (clk, reset_n)
    Begin
        If (reset_n = '0') Then 
            current_state <= SWEEP_RIGHT; --Default state to move right 
        Elsif (rising_edge(clk)) Then 
            current_state <= next_state;  --Go to next state 
        End If; 
    End Process;
  
    Process (current_state, write, up_angle_count, down_angle_count, address, RAM_angle_limit,
           current_lower_angle_limit, current_upper_angle_limit)
    Begin 
        Case (current_state) IS 
            When SWEEP_RIGHT => 
                irq <= '0'; -- Set irq flag low (Angle Limit not reached yet)
                If (address = "01") Then                                   --If register 1 is accessed Then
                    If (up_angle_count = RAM_angle_limit) Then             -- If up_angle_count = RAM_angle_limit Then
                        irq <= '1';                                        -- set irq to 1 
                        next_state <= WAIT_1;                              -- go to WAIT_1 state
                    Else                                                   -- Else
                        next_state <= SWEEP_RIGHT;                         -- Stay in SWEEP_RIGHT state
                    End if;                                                
                Else                                                       --If register 1 is not accessed Then
                    If (up_angle_count = current_upper_angle_limit) Then   -- If up_angle_count = current_upper_angle_limit Then
                        irq <= '1';                                        -- set irq to 1 
                        next_state <= WAIT_1;                              -- go to WAIT_1 state
                    Else                                                   -- Else
                        next_state <= SWEEP_RIGHT;                         -- Stay in SWEEP_RIGHT state
                    End if;                                                 
                End If;                                                    
                                                                           
            When WAIT_1 =>                                                 
                If (write = '1') Then                                      --If write = '1' Then 
                    irq <= '0';                                            --irq is cleared
                    next_state <= SWEEP_LEFT;                              --go to SWEEP_LEFT state
                Else                                                       --Else 
                    next_state <= WAIT_1;                                  --Stay in WAIT_1 state
                End If;
          
            When SWEEP_LEFT => 
                If (address = "00") Then                                   --If register 0 is accessed Then
                    If (down_angle_count = RAM_angle_limit) Then           -- If down_angle_count = RAM_angle_limit Then
                        irq <= '1';                                        -- set irq to 1 
                        next_state <= WAIT_2;                              -- go to WAIT_2 state
                    Else                                                   -- Else
                        next_state <= SWEEP_LEFT;                          -- Stay in SWEEP_LEFT state
                    End If;                                                     
                Else                                                       --If register 0 is not accessed Then
                    If (down_angle_count = current_lower_angle_limit) Then -- If down_angle_count = current_lower_angle_limit Then
                        irq <= '1';                                        -- set irq to 1 
                        next_state <= WAIT_2;                              -- go to WAIT_2 state
                    Else                                                   -- Else
                        next_state <= SWEEP_LEFT;                          -- Stay in SWEEP_LEFT state
                    End If;                                                     
                End If; 

            When WAIT_2 =>                                                
                If (write = '1') Then                                      --If write = '1' Then
                    irq <= '0';                                            --irq is cleared
                    next_state <= SWEEP_RIGHT;                             --go to SWEEP_RIGHT state
                Else                                                       --Else
                    next_state <= WAIT_2;                                  --Stay in WAIT_2 state
                End If;                                                    
                                                                   
            When Others =>                                                 --Safty Net Clause 
                next_state <= SWEEP_RIGHT; 
        End Case;
    End Process;
End beh; 

