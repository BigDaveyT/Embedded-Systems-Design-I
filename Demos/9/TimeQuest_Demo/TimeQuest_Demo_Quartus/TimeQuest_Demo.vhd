library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity TimeQuest_Demo is
    port
    (
        CLOCK_50 : in  std_logic;
        input_A   : in  std_logic_vector(15 downto 0);
        input_B   : in  std_logic_vector(15 downto 0);
        KEY       : in  std_logic_vector( 3 downto 0);
        output    : out std_logic_vector(15 downto 0)
    );
        
end TimeQuest_Demo;

architecture arch of TimeQuest_Demo is

    --SIGNAL DECLARATIONS--
    signal reset_n  : std_logic;
    signal key0_d1  : std_logic;
    signal key0_d2  : std_logic;
    signal key0_d3  : std_logic;
    signal sync_A   : std_logic_vector(15 downto 0);
    signal sync_B   : std_logic_vector(15 downto 0);
    signal sync_sum : std_logic_vector(15 downto 0);
    
    
    component Synchronizer is
        port
        (
            clk       :  in std_logic;
            reset_n   :  in std_logic;
            async_in  :  in std_logic_vector(15 downto 0);
            sync_out : out std_logic_vector(15 downto 0)
        );
    end component Synchronizer;
        
    begin
        
        ----- Syncronize the reset
        synchReset_proc : process (CLOCK_50) begin
            if (rising_edge(CLOCK_50)) then
                key0_d1 <= KEY(0);
                key0_d2 <= key0_d1;
                key0_d3 <= key0_d2;
            end if;
        end process synchReset_proc;
		  
		  reset_n <= not key0_d3;
    
    Synchonizer_1 : Synchronizer
    Port Map
    (     
        clk      => CLOCK_50,
        reset_n    => reset_n,
        async_in => input_A,
        sync_out => sync_A
    );
    
    
    Synchonizer_2 : Synchronizer
    Port Map
    (
        clk         => CLOCK_50,
        reset_n     => reset_n,
        async_in    => input_B,
        sync_out    => sync_B
    );
    
    sync_sum <= sync_A + sync_B;  --here is the addition
    
    Synchonizer_Sum : Synchronizer

    Port Map
    (
        clk      => CLOCK_50,
        reset_n    => reset_n,
        async_in => sync_sum,
        sync_out => output
    );

end arch;
