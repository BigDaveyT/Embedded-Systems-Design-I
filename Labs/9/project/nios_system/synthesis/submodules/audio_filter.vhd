library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity audio_filter is
    port
    (
        
        clk          : in  std_logic;                     -- clock signal
        reset_n      : in  std_logic;                     -- reset signal
        address      : in  std_logic;                     -- to differentiate low(0) and high(1)
        writedata    : in  std_logic_vector(15 downto 0); -- audio sample
        write        : in  std_logic;                     -- 0 or 1 to write or not

        readdata     : out std_logic_vector(15 downto 0)  -- filtered audio signal (from handout)
    );
end audio_filter;

architecture arch of audio_filter is

    ---------------------------------------------
    -- 2D array to store the data (both low and high)
    ----------------------------------------------
    type process_low_or_high_pass is array (0 to 16, 0 to 1) of signed(15 downto 0);
    signal audio_filter_array : process_low_or_high_pass :=
    (
        -- Low       High
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

    --------------------------
    -- Component Declaration
    --------------------------
    COMPONENT multiplier IS
        PORT
        (
            dataa  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            datab  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT multiplier;

    ---------------------------------------------
    -- 1D array to store data after multiplying
    ----------------------------------------------
    type multiplied_data is array (0 to 16) of signed(31 downto 0);
    signal multiplied_data_signal : multiplied_data;

    ---------------------------------------------
    -- 1D array to store data after shifting
    ----------------------------------------------
    type shifted_data is array (0 to 16) of signed(15 downto 0);
    signal shifted_data_signal : shifted_data ;

    ---------------------------------------------
    -- The register for high and low pass and audio data storage
    ----------------------------------------------
    type ram_type is array (0 to 17) of signed(15 downto 0);
    signal registers : ram_type ;

    -- registers(0) this will be storing the data to let me know if its a low or high pass will be (0xFF) or (0x00),every time the switch interrupt goes, store that value into registers(0) and that will let us knoe if it is low or high pass
    -- registers(1) this will actually store the audio data
    
    --------------------------
    -- signal Declarations
    --------------------------
    signal input_data  : signed(15 downto 0) := (others => '0');
    signal index       : integer; 
    signal output_data : signed(15 downto 0) := (others => '0'); 
    -----------------------------------------------------

    BEGIN
    -----------------------------------------------------
    -- generate 16 port maps for every variable constant
    -----------------------------------------------------
    audio_filtering :

    for i in 0 to 16 generate
    
        REGX : multiplier 
    
        port map
        (
            dataa          => std_logic_vector(shifted_data_signal(i)),
            datab          => std_logic_vector(audio_filter_array(i, index)),
            signed(result) => multiplied_data_signal(i)
        );
            
    end generate audio_filtering;
            
    -----------------------------------------------------
    -- Depending on the audio_filter enable the index will either be a 1 or a 0 for the low or high pass audio_filter
    -----------------------------------------------------
    process_low_or_high: process(reset_n, clk)
    BEGIN
        if(reset_n = '0') THEN
            index <= 0;
        elsif(rising_edge(clk)) then
            if(registers(0) = X"F") then
                index <= 1;
            else
                index <= 0;
            end if;
        end if;
    end process;

    ----------------------------------------------------
    -- creating the output readdata vector
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
    -- shift the data
    -----------------------------------------------------
    process_shifted_data_signal: PROCESS(clk, reset_n)
    BEGIN
        IF (clk'event AND clk = '1') THEN
            IF (reset_n = '0') THEN
                shifted_data_signal <= (others => (others=> '0'));
            elsif(write = '1') THEN
                shifted_data_signal(0) <= signed(writedata);
                for G in 1 to shifted_data_signal'length-1 loop
                    shifted_data_signal(G)   <=  shifted_data_signal(G-1);
                end loop;
            end if;
        end if;
    END PROCESS process_shifted_data_signal; 
end arch;
