-------------------------------------------------------------------------
-- Name:        David Tassoni
-- Course:      CPET 561-01
-- Assignment:  Lab 5 
-- File:        Lab_5_Servo_Controller.vhd
-- copied from lab4
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Lab_4_Servo_Controller is
    Port
    (
        clk         : IN  STD_LOGIC;
        reset_n     : IN  STD_LOGIC;
        write       : IN  STD_LOGIC;
        writedata   : IN  UNSIGNED(31 downto 0);
        address     : IN  STD_LOGIC_VECTOR(1 downto 0);
        wave_out    : OUT STD_LOGIC;
        irq         : OUT STD_LOGIC := '0'
    );
end entity Lab_4_Servo_Controller;

architecture beh of Lab_4_Servo_Controller is

    -- Signal and Constant Decalarations  --
    constant Default_Angle_Min : unsigned(31 downto 0) := x"0000C350"; -- 45  degrees (50,000)
    constant Default_Angle_Max : unsigned(31 downto 0) := x"000186A0"; -- 135 degrees (100,000)
    constant max_count         : unsigned(31 downto 0) := x"000F4240"; -- 20ms/ 20ns = 1,000,000
    constant address_0         : std_logic_vector(1 downto 0):= "00";
    constant address_1         : std_logic_vector(1 downto 0):= "01";
    
    signal   period_count      : unsigned(31 downto 0) := (others => '0');
    signal   up_angle_count    : unsigned(31 downto 0) := x"0000C350"; -- Starting point (50,000)
    signal   down_angle_count  : unsigned(31 downto 0) := x"000186A0"; -- Starting point (100,000)
    
    signal   current_lower_angle_limit : unsigned(31 downto 0) := x"0000C350"; -- 50,000
    signal   current_upper_angle_limit : unsigned(31 downto 0) := x"000186A0"; -- 100,000
    
    signal   RAM_angle_limit : unsigned(31 downto 0);
    
    ---- RAM ----
    type     ram_type is array (1 downto 0) of unsigned(31 downto 0);
    signal   Registers : ram_type := (others => (others => '0'));
    
    ---- STATE ----
    type     state_type IS (SWEEP_RIGHT, WAIT_1, SWEEP_LEFT, WAIT_2); -- state names from handout
    signal   current_state, next_state: state_type;

    begin
        -- RAM --
        ram_inst_proc : process(clk,reset_n, write) 
        begin
            if (reset_n = '0') then 
                Registers(to_integer(unsigned(address_0))) <= x"0000C350"; -- 50000   limit for end of sweep left
                Registers(to_integer(unsigned(address_1))) <= x"000186A0"; -- 100000  limit for end of sweep right
            elsif (rising_edge(clk)) then
                if (write = '1') then    
                    Registers(to_integer(unsigned(address))) <= writedata; 
                end if;
            RAM_angle_limit <= Registers(to_integer(unsigned(address))); 
            end if;
        end process ram_inst_proc;
  
        --20ms Max Counter 
        timer_count_proc : process(clk, reset_n)
        begin
            if (reset_n = '0') then 
                period_count <= (others => '0');
            elsif (rising_edge(clk)) then
                if (period_count = max_count) then 
                    period_count <= (others => '0');
                else 
                    period_count <= period_count + 1;
                end if;
            end if; 
        end process timer_count_proc; 

        -- Max Angle Counter process
        angle_count_proc : process(clk, reset_n, current_state, address, period_count, up_angle_count, down_angle_count, current_upper_angle_limit, 
                current_lower_angle_limit)
        begin
            if (reset_n = '0') then 
                up_angle_count   <= Default_Angle_Min; -- reset to default
                down_angle_count <= Default_Angle_Max; -- reset to default
            elsif (rising_edge(clk)) then
                -- Sets width of pulse in the SWEEP_RIGHT state --
                -- increments when the period count is less than or equal to the max up angle count --
                if (current_state = SWEEP_RIGHT) then
                    if (period_count <= up_angle_count) then
                        wave_out <= '1';
                    elsif (period_count > up_angle_count) then
                        wave_out <= '0';
                    end if;
        ----------------------------------------------

                -- Sets width of pulse in SWEEP_LEFT state --
                -- increments when the period count is less than or equal to the max down angle count --
                elsif (current_state = SWEEP_LEFT) then
                    if (period_count <= down_angle_count) then
                        wave_out <= '1';
                    elsif (period_count > down_angle_count) then
                        wave_out <= '0';
                    end if;
        ----------------------------------------------

                -- Update of current_lower_angle_limit from RAM in WAIT_1 state --
                elsif (current_state = WAIT_1) then
                    if (address = "00" ) then 
                        current_lower_angle_limit <= RAM_angle_limit;
                    else 
                        null;
                    end if;
            
                down_angle_count <= up_angle_count; --Update of down_angle_count w/ current up_angle_count
        -------------------------------------------------------------------

                --Update of current_upper_angle_limit from RAM in WAIT_2 state-----
                elsif (current_state = WAIT_2) then 
                    if (address = "01" ) then 
                        current_upper_angle_limit <= RAM_angle_limit;
                    else 
                        null;
                    end if;
                    
                up_angle_count <= down_angle_count; --Update of up_angle_count w/ current down_angle_count
            
                end if;
         -------------------------------------------------------------------

            -- Increments/Decrements the angle count at the end of 20 ms period --
            if (period_count = max_count) then
                if (up_angle_count < current_upper_angle_limit) then
                    up_angle_count <= up_angle_count + x"00001388"; -- increment by step size of 5000
                elsif (down_angle_count > current_lower_angle_limit) then
                    down_angle_count <= down_angle_count - x"00001388"; -- decrement by step size of 5000
                end if; 
            end if; 
         --------------------------------------------------------------------------------------- 
        end if; 
    end process angle_count_proc; 

    --State Machine 
    FSM_proc : process (clk, reset_n)
    begin
        if (reset_n = '0') then 
            current_state <= SWEEP_RIGHT; -- Default state SWEEP_RIGHT 
        elsif (rising_edge(clk)) then 
            current_state <= next_state;  -- Go to the next state 
        end if; 
    end process FSM_proc;

    state_machine_proc : process (current_state, write, up_angle_count, down_angle_count, address, RAM_angle_limit,
           current_lower_angle_limit, current_upper_angle_limit)
    begin 
        case (current_state) IS 
            when SWEEP_RIGHT => 
                irq <= '0'; -- Set the irq flag low (0) since Angle Limit is not reached
                if (address = "01") then                                   -- if register 1 is accessed
                    if (up_angle_count = RAM_angle_limit) then             -- if up_angle_count = RAM_angle_limit
                        irq <= '1';                                        -- set irq flag to 1 
                        next_state <= WAIT_1;                              -- go to WAIT_1 state
                    else                                                   -- else
                        next_state <= SWEEP_RIGHT;                         -- stay in SWEEP_RIGHT state
                    end if;                                                
                else                                                       -- if register 1 is not accessed
                    if (up_angle_count = current_upper_angle_limit) then   -- if up_angle_count = current_upper_angle_limit
                        irq <= '1';                                        -- set irq to 1 
                        next_state <= WAIT_1;                              -- go to WAIT_1 state
                    else                                                   -- else
                        next_state <= SWEEP_RIGHT;                         -- Stay in SWEEP_RIGHT state
                    end if;                                                 
                end if;                                                    
                                                                           
            when WAIT_1 =>                                                 
                if (write = '1') then                                      -- if write = '1'
                    irq <= '0';                                            -- irq is cleared to 0
                    next_state <= SWEEP_LEFT;                              -- go to SWEEP_LEFT state
                else                                                       -- else 
                    next_state <= WAIT_1;                                  -- Stay in WAIT_1 state
                end if;
          
            when SWEEP_LEFT => 
                if (address = "00") then                                   -- if register 0 is accessed
                    if (down_angle_count = RAM_angle_limit) then           -- if down_angle_count = RAM_angle_limit then
                        irq <= '1';                                        -- set irq flag to 1
                        next_state <= WAIT_2;                              -- go to WAIT_2 state
                    else                                                   -- else
                        next_state <= SWEEP_LEFT;                          -- Stay in SWEEP_LEFT state
                    end if;                                                     
                else                                                       -- if register 0 is not accessed then
                    if (down_angle_count = current_lower_angle_limit) then -- if down_angle_count = current_lower_angle_limit then
                        irq <= '1';                                        -- set irq to 1 
                        next_state <= WAIT_2;                              -- go to WAIT_2 state
                    else                                                   -- else
                        next_state <= SWEEP_LEFT;                          -- Stay in SWEEP_LEFT state
                    end if;                                                     
                end if; 

            when WAIT_2 =>                                                
                if (write = '1') then                                      -- if write = '1'
                    irq <= '0';                                            -- irq is cleared
                    next_state <= SWEEP_RIGHT;                             -- go to SWEEP_RIGHT state
                else                                                       -- else
                    next_state <= WAIT_2;                                  -- Stay in WAIT_2 state
                end if;                                                    
                                                                   
            when Others =>                                                 -- Safty Net Clause just in case!
                next_state <= SWEEP_RIGHT; 
        end case;
    end process state_machine_proc;
end beh; 

