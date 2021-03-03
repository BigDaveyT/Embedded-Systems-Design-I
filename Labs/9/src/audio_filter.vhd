---------------------------------------
------------ David Tassoni ------------
---------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity audio_filter is
    port
    (
        clk       : in  std_logic;                     -- clock signal
        reset_n   : in  std_logic;                     -- reset signal
        address   : in  std_logic;                     -- to differentiate low(0) and high(1)
        writedata : in  std_logic_vector(15 downto 0); -- audio sample
        write     : in  std_logic;                     -- 0 or 1 to write or not

        readdata  : out std_logic_vector(15 downto 0)  -- filtered audio signal (from handout)
    );
end audio_filter;

architecture arch of audio_filter is

    -------------------------------------------------
    -- 2D array to store the data (both low and high)
    -------------------------------------------------
    type low_or_high_pass_array is array (0 to 16, 0 to 1) of signed(15 downto 0);
    signal audio_filter_array : low_or_high_pass_array :=
    (
      -- Low (0)   High (1)
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

    ---------------------------
    -- Component Declaration --
    -- created in lab 8 --
    ---------------------------
    component multiplier IS
    PORT
    (
        dataa  : in  std_logic_vector(15 downto 0);
        datab  : in  std_logic_vector(15 downto 0);
        result : out std_logic_vector(31 downto 0)
    );
    end component multiplier;

    -------------------------------------------
    -- Array to store data after multiplying --
    -------------------------------------------
    type   multiplied_data is array (0 to 16) of signed(31 downto 0);
    signal multiplied_data_signal : multiplied_data;

    ---------------------------------------------
    -- Array to store data after shifting --
    ----------------------------------------------
    type   shifted_data is array (0 to 16) of signed(15 downto 0);
    signal shifted_data_signal : shifted_data ;

    ---------------------------------------------------------
    -- Register for high and low pass and audio data storage
    ---------------------------------------------------------
    type   ram_type is array (0 to 17) of signed(15 downto 0);
    signal registers : ram_type ;

    -- registers(0)
    -- registers(1) stores the audio data
    
    --------------------------
    -- Signal Declaration
    --------------------------
    signal index : integer; -- same as int i from other coding languages
    -----------------------------------------------------

    begin
    -----------------------------------------------------
    -- generate 16 port maps for every variable constant
    -----------------------------------------------------
    audio_filter : for i in 0 to 16 generate
        mult : multiplier 
        port map
        (
            dataa          => std_logic_vector(shifted_data_signal(i)),
            datab          => std_logic_vector(audio_filter_array(i, index)),
            signed(result) => multiplied_data_signal(i)
        );
            
    end generate audio_filter;

    -----------------------------------------------------
    -- Index will either be low/high (0 vs 1)
    -----------------------------------------------------
    low_or_high_proc: process(reset_n, clk)
    begin
        if(reset_n = '0') then
            index <= 0;     -- low pass
        elsif(rising_edge(clk)) then
            if(registers(0) = X"F") then
                index <= 1; -- high pass
            else
                index <= 0; -- low pass
            end if;
        end if;
    end process low_or_high_proc;

    ----------------------------------------------------
    -- The output readdata vector
    ----------------------------------------------------
    readdata <= std_logic_vector
    (
        multiplied_data_signal  (0) (30 downto 15)
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
        + multiplied_data_signal(16)(30 downto 15)
    );

    ----------------------------------------------------
    -- Shift the data
    ----------------------------------------------------
    shifted_data_signal_proc: process(clk, reset_n)
    begin
        if (clk'event AND clk = '1') then
            if (reset_n = '0') then
                shifted_data_signal <= (others => (others=> '0'));
            elsif(write = '1') then
                shifted_data_signal(0) <= signed(writedata);
                for j in 1 to shifted_data_signal'length-1 loop
                    shifted_data_signal(j)   <=  shifted_data_signal(j-1);
                end loop;
            end if;
        end if;
    end process shifted_data_signal_proc; 
end arch;
