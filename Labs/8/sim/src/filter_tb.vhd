-- David Tassoni
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

entity filter_tb is
end filter_tb;

architecture arch of filter_tb is
    component lowFilter is        -- change between low and high depending on which file is being processed
    port
    (
        clock     : in std_logic;
        KEY       : in std_logic;
        filter_en : in std_logic;
        data_in   : in signed(15 downto 0); 
        data_out  : out signed(15 downto 0) 
    );
    end component;

    signal sim_done  : boolean := false;
    constant period  : time := 20 ns;                                              
    signal clk       : std_logic := '0';
    signal reset_n   : std_logic ;
    signal filter_en : std_logic := '0'; 
    signal data_in   : signed(15 downto 0):= (others => '0');
    signal data_out  : signed(15 downto 0):= (others => '0');
    type   tb_array  is array (0 to 39) of signed(15 downto 0);

    signal tb_array_signal : tb_array; -- (called audioSampleArray on handout)

    begin
        uut: lowFilter 
        port map
        (
            clock     => clk,
            KEY       => reset_n,
            filter_en => filter_en,
            data_in   => data_in,
            data_out  => data_out
        );

        -- clock process
        clock_proc : process
        begin
            clk <= not clk;
            wait for period/2;
        end process clock_proc;

        -- reset process
        async_reset_proc : process
        begin
            reset_n<= '0';
            wait for 2 * period;
            reset_n <= '1';
            wait;
        end process async_reset_proc; 

    stimulus : process is
        file read_file    : text open read_mode  is "../src/verification_src/one_cycle_200_8k.csv";
        file results_file : text open write_mode is "../src/verification_src/output_waveform.csv";
        variable lineIn : line;
        variable lineOut : line;
        variable readValue : integer;
        variable writeValue : integer;
        begin
            -- wait for 100 ns;
            -- Read data from file into an array
            for i in 0 to 39 loop
                readline(read_file, lineIn);
                read(lineIn, readValue);
                tb_array_signal(i) <= to_signed(readValue, 16);
                wait for 50 ns;
            end loop;
            file_close(read_file);
            
            -- Apply the test data and put the result into an output file
            for i in 1 to 10 loop
                for j in 0 to 39 loop
                    data_in <= tb_array_signal(j); -- read through the file line by line and populate the array
                    filter_en <= '1';
                    wait until rising_edge (clk);
                    filter_en <= '0';

                    -- Write filter output to file
                    writeValue := to_integer(data_out);
                    write(lineOut, writeValue);
                    writeline(results_file, lineOut);
                end loop;
            end loop;
        
        file_close(results_file);
        -- end simulation
        sim_done <= true;
        wait for 100 ns;

        -- last wait statement needs to be here to prevent the process
        -- sequence from re starting at the beginning
        wait;

    end process stimulus;
end arch;