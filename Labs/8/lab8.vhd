-- David Tassoni

library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity lab8 is

port
(
    clock     : in std_logic;
    -- reset_n   : in  std_logic;                     -- reset signal
    KEY       : in std_logic;
    data_in   : in signed(15 downto 0);
    filter_en : in std_logic;
    data_out  : out signed(15 downto 0)
);
    
end lab8;

architecture arch of lab8 is

    type filter_array is array (0 to 16, 0 to 1) of signed (15 downto 0);
    
    signal lowhigh_pass_array : filter_array :=
    
    (    
    --   LOW       HIGH  values from lab handout
        (X"0051" , X"003E"),
        (X"00BA" , X"FF9A"),
        (X"01E1" , X"FE9E"),
        (X"0408" , X"0000"),
        (X"071A" , X"0535"),
        (X"0AAC" , X"05B2"),
        (X"0E11" , X"F5AC"),
        (X"107F" , X"DAB7"),
        (X"1161" , X"4C91"),
        (X"107F" , X"DAB7"),
        (X"0E11" , X"F5AC"),
        (X"0AAC" , X"05B2"),
        (X"071A" , X"0535"),
        (X"0408" , X"0000"),
        (X"01E1" , X"FE9E"),
        (X"00BA" , X"FF9A"),
        (X"0051" , X"003E")
    );
        
    
    -- One directional array to store data from multiplier
    type multiplied_data is array (0 to 16) of signed(31 downto 0);
    signal multiplied_data_signal : multiplied_data;

    -- one directional array to store data from shifting
    type shifted_data is array (0 to 16) of signed(15 downto 0);
    signal shifted_data_signal : shifted_data;

    -- component declaration --
    Component multiplier is
        port
        (
            dataa  :  IN std_logic_vector(15 downto 0);
            datab  :  IN std_logic_vector(15 downto 0);
            result : OUT std_logic_vector(31 downto 0)
        );
	end component multiplier;
    
    -- signal declarations --
    signal  input_data : signed(15 downto 0) := (others => '0');
    signal output_data : signed(15 downto 0) := (others => '0');
    signal reset_n : std_logic;
    signal key0_d1 : std_logic;
    signal key0_d2 : std_logic;
    signal key0_d3 : std_logic;
    
    BEGIN
        -- synchronize the reset --
        synchReset_proc : process(clock) begin
            if (rising_edge(clock)) then
                key0_d1 <= KEY;
                key0_d2 <= key0_d1;
                key0_d3 <= key0_d2;
            end if;
        end process synchReset_proc;
        
        reset_n <= key0_d3;
        
        LowPass : for i in 0 to 16 generate
        
            MULT : multiplier
                
            port map
            (
                dataa => std_logic_vector(shifted_data_signal(i)),
                datab => std_logic_vector(lowhigh_pass_array(i, 0)),
                signed(result) => multiplied_data_signal(i)
            );
        end generate LowPass;
        
        data_out <=  multiplied_data_signal(0) (30 downto 15)
                   + multiplied_data_signal(1) (30 downto 15)
                   + multiplied_data_signal(2) (30 downto 15)
                   + multiplied_data_signal(3) (30 downto 15)
                   + multiplied_data_signal(4) (30 downto 15)
                   + multiplied_data_signal(5) (30 downto 15)
                   + multiplied_data_signal(6) (30 downto 15)
                   + multiplied_data_signal(7) (30 downto 15)
                   + multiplied_data_signal(8) (30 downto 15)
                   + multiplied_data_signal(9) (30 downto 15)
                   + multiplied_data_signal(10)(30 downto 15)
                   + multiplied_data_signal(11)(30 downto 15)
                   + multiplied_data_signal(12)(30 downto 15)
                   + multiplied_data_signal(13)(30 downto 15)
                   + multiplied_data_signal(14)(30 downto 15)
                   + multiplied_data_signal(15)(30 downto 15)
                   + multiplied_data_signal(16)(30 downto 15);
                
        data_shift : process(clock, reset_n)
        begin
            if (clock'event AND clock = '1') then
                if(reset_n = '0') then
                    shifted_data_signal <= (others => (others => '0'));
                elsif(filter_en = '1') then
                    shifted_data_signal(0) <= data_in;
                    for j in 1 to shifted_data_signal'length-1 loop
                        shifted_data_signal(j) <= shifted_data_signal(j-1);
                    end loop;
                end if;
            end if;
        end process data_shift;
end arch;
                