-- David Tassoni
-- high-pass filter

library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;


entity highFilter is
    port
    (
        clock     : in  std_logic;
        KEY       : in  std_logic;
        data_in   : in  signed(15 downto 0);
        filter_en : in  std_logic;

        data_out  : out signed(15 downto 0)
    );
end highFilter;


architecture arch of highFilter is

---- high-pass array to hold the data ----
type   high_pass is array (0 to 16) of signed(15 downto 0);
signal high_pass_signal : high_pass :=
(
    -- array of numbers to pass through the high pass array, obtained from handout
    X"003E",
    X"FF9A",
    X"FE9E",
    X"0000",
    X"0535",
    X"05B2",
    X"F5AC",
    X"DAB7",
    X"4C91",
    X"DAB7",
    X"F5AC",
    X"05B2",
    X"0535",
    X"0000",
    X"FE9E",
    X"FF9A",
    X"003E"
);

---- Array to store data after multiplier ----
type   multiplied_data is array (0 to 16) of signed(31 downto 0);
signal multiplied_data_signal : multiplied_data ;

---- Array to store data after shifting ----
type   shifted_data is array (0 to 16) of signed(15 downto 0);
signal shifted_data_signal : shifted_data ;


component multiplier IS
PORT
(
    dataa  : in  std_logic_vector (15 downto 0);
    datab  : in  std_logic_vector (15 downto 0);
    result : out std_logic_vector (31 downto 0)
    );

END component multiplier;

--------------------------                        
-- Signal Declarations
--------------------------
    
-- signal input_data            : signed(15 downto 0)   := (others => '0');
-- signal output_data           : signed(15 downto 0)   := (others => '0'); 
 
signal reset_n : std_logic;
signal key0_d1 : std_logic;
signal key0_d2 : std_logic;
signal key0_d3 : std_logic;

begin
 
-----------------------------------------------------                     
  ----- Syncronize the reset
-----------------------------------------------------  
synchReset_proc : process (clock) begin
    if (rising_edge(clock)) then
        key0_d1 <= KEY;
        key0_d2 <= key0_d1;
        key0_d3 <= key0_d2;
    end if;
end process synchReset_proc;

reset_n <= key0_d3;


LowPass: for i in 0 to 16 generate
    MULT : multiplier 
    port map
    (
        dataa          => std_logic_vector(shifted_data_signal(i) ),
        datab          => std_logic_vector(high_pass_signal(i)),
        signed(result) => multiplied_data_signal(i)
    );
end generate LowPass;

---- write to the data_out output ----
data_out <=  
    multiplied_data_signal(0) (30 downto 15)
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
  

---- shift the data ----
shifted_data_proc: PROCESS(clock,reset_n)
begin
    IF (clock'event AND clock = '1') THEN
        IF (reset_n = '0') THEN
            shifted_data_signal <= ( others => ( others=> '0') );
        elsif(filter_en = '1') THEN
            shifted_data_signal(0) <= data_in;
            for j in 1 to shifted_data_signal'length-1 loop
                shifted_data_signal(j)   <=  shifted_data_signal(j-1);
            end loop;
        end if;
    end if;
END PROCESS shifted_data_proc; 

end arch;