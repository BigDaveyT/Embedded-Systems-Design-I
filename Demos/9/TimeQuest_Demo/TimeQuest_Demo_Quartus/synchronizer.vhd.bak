library ieee;
use ieee.std_logic_1164.all;

entity Synchronizer is
    port
    (
        clk      :  in std_logic;
        reset_n  :  in std_logic;
        async_in :  in std_logic_vector(15 downto 0);
        sync_out : out std_logic_vector(15 downto 0)
    );
    
end Synchronizer;
    
architecture beh of Synchronizer is

    -- SIGNAL DECLARATIONS --
    signal flop_1 : std_logic_vector(15 downto 0);
    signal flop_2 : std_logic_vector(15 downto 0);
    
    begin
    
        double_flop :process(reset_n,clk,async_in)
        begin
            if (reset_n = '0') then
                flop_1 <= "0000000000000000";
                flop_2 <= "0000000000000000";
            
            elsif (rising_edge(clk)) then
                flop_1 <= async_in;
                flop_2 <= flop_1;
            end if;
        end process;
    sync_out <= flop_2;
end beh;