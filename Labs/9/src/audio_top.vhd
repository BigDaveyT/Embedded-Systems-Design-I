---------------------------------------
------------ David Tassoni ------------
---------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.all;
USE ieee.std_logic_signed.all;

entity audio_top IS
    port
    (
        ---- CLOCK ----
        CLOCK_50                                  : in    std_logic;
        ---- KEY ----
        KEY                                       : in    std_logic_vector (3 downto 0);
        ---- SWITCHES ----
        SW                                        : in    std_logic_vector (7 downto 0);


        DRAM_CLK,DRAM_CKE                         : out   std_logic;
        DRAM_ADDR                                 : out   std_logic_vector(12 downto 0);
        DRAM_BA                                   : out   std_logic_vector(1  downto 0);
        DRAM_CS_N,DRAM_CAS_N,DRAM_RAS_N,DRAM_WE_N : out   std_logic;
        DRAM_DQ                                   : inout std_logic_vector(15 downto 0);
        DRAM_UDQM,DRAM_LDQM                       : out   std_logic;

        AUD_ADCDAT                                : in    std_logic;
        AUD_ADCLRCK                               : inout std_logic;
        AUD_BCLK                                  : inout std_logic;
        AUD_DACDAT                                : out   std_logic;
        AUD_DACLRCK                               : inout std_logic;
        AUD_XCK                                   : out   std_logic;

        -- the_audio_and_video_config_0
        FPGA_I2C_SCLK                             : out   std_logic;
        FPGA_I2C_SDAT                             : inout std_logic;

        LEDR                                      : out   std_logic_vector(9  downto 0); -- WAS 7

        GPIO_0                                    : inout std_logic_vector(35 downto 0)
    );
END audio_top;

ARCHITECTURE rtl OF audio_top IS

    component nios_system is
        port
        (            
            AUD_ADCDAT_to_the_audio_0   : in    std_logic := '0';                                 -- audio.ADCDAT
            AUD_ADCLRCK_to_the_audio_0  : in    std_logic := '0';                                 -- ADCLRCK
            AUD_BCLK_to_the_audio_0     : in    std_logic := '0';                                 -- BCLK
            AUD_DACDAT_from_the_audio_0 : out   std_logic;                                        -- DACDAT
            AUD_DACLRCK_to_the_audio_0  : in    std_logic := '0';                                 -- DACLRCK
            clk_clk                     : in    std_logic := '0';                                 -- clk.clk
            i2c_SDAT                    : inout std_logic := '0';                                 -- i2c.SDAT
            i2c_SCLK                    : out   std_logic;                                        -- .SCLK
            pin_export                  : out   std_logic;                                        -- pin.export
            reset_reset                 : in    std_logic := '0';                                 -- reset.reset
            sdram_addr                  : out   std_logic_vector(12 downto 0);                    -- sdram.addr
            sdram_ba                    : out   std_logic_vector(1 downto 0);                     -- .ba
            sdram_cas_n                 : out   std_logic;                                        -- .cas_n
            sdram_cke                   : out   std_logic;                                        -- .cke
            sdram_cs_n                  : out   std_logic;                                        -- .cs_n
            sdram_dq                    : inout std_logic_vector(15 downto 0) := (others => '0'); -- .dq
            sdram_dqm                   : out   std_logic_vector(1 downto 0);                     -- .dqm
            sdram_ras_n                 : out   std_logic;                                        -- .ras_n
            sdram_we_n                  : out   std_logic;                                        -- .we_n
            sdram_clk_clk               : out   std_logic;                                        -- sdram_clk.clk
            switches_export             : in    std_logic_vector(7 downto 0)  := (others => '0')  -- switches.export
        );
    end component nios_system;

    ----------------------------------------------------------------------------
    --               Internal Wires and Registers Declarations                --
    ----------------------------------------------------------------------------
    signal reset_n         : std_logic;
    signal DRAM_DQM        : std_logic_vector(1 downto 0);
    signal int_AUD_BCLK    : std_logic;
    signal int_AUD_DACDAT  : std_logic;
    signal int_AUD_DACLRCK : std_logic;
    signal count           : std_logic_vector(3 downto 0);
    signal test_sig        : std_logic;
    signal key0_d1         : std_logic;
    signal key0_d2         : std_logic;
    signal key0_d3         : std_logic;

    begin

        LEDR_process : process(CLOCK_50, reset_n)
        begin
            if (reset_n = '0') then
                LEDR <= "1111111111";
            elsif (rising_edge(CLOCK_50)) then
                LEDR <= "0011001100";
            end if;
        end process LEDR_process;

        AUD_XCK <= count(1);
        DRAM_UDQM <= DRAM_DQM(1);
        DRAM_LDQM <= DRAM_DQM(0);
        AUD_DACDAT <= int_AUD_DACDAT;
        GPIO_0(0) <= AUD_BCLK;
        GPIO_0(1) <= int_AUD_DACDAT;
        GPIO_0(2) <= AUD_DACLRCK;
        GPIO_0(3) <= test_sig;

        ---------------------------------------
        ---- clock process from audio demo ----
        ---------------------------------------
        clkgen_proc: process(CLOCK_50, reset_n)
        begin
            if (reset_n = '0') then -- was 1
                count <= "0000";
            elsif (rising_edge(CLOCK_50)) then
                count <= count + 1;
            end if;
        end process clkgen_proc;

        -------------------------------
        ---- synchronize the reset ----
        -------------------------------
        synchReset_proc : process (CLOCK_50)
        begin
            if (rising_edge(CLOCK_50)) then
                key0_d1 <= KEY(0);
                key0_d2 <= key0_d1;
                key0_d3 <= key0_d2;
            end if;
        end process synchReset_proc;
        reset_n <= key0_d3;

        ----------------------------------------
        ---- nios system component port map ----
        ----------------------------------------
        u0 : component nios_system
        port map
        (
            AUD_ADCDAT_to_the_audio_0     => AUD_ADCDAT,
            AUD_ADCLRCK_to_the_audio_0    => AUD_ADCLRCK,
            AUD_BCLK_to_the_audio_0       => AUD_BCLK,
            AUD_DACDAT_from_the_audio_0   => int_AUD_DACDAT,
            AUD_DACLRCK_to_the_audio_0    => AUD_DACLRCK,
            clk_clk                       => CLOCK_50,
            i2c_SDAT                      => FPGA_I2C_SDAT,
            i2c_SCLK                      => FPGA_I2C_SCLK,
            pin_export                    => test_sig,
            reset_reset                   => not reset_n, -- not was added
            sdram_addr                    => DRAM_ADDR,
            sdram_ba                      => DRAM_BA,
            sdram_cas_n                   => DRAM_CAS_N,
            sdram_cke                     => DRAM_CKE,
            sdram_cs_n                    => DRAM_CS_N,
            sdram_dq                      => DRAM_DQ,
            sdram_dqm                     => DRAM_DQM,
            sdram_ras_n                   => DRAM_RAS_N,
            sdram_we_n                    => DRAM_WE_N,
            sdram_clk_clk                 => DRAM_CLK,
            switches_export               => SW(7 downto 0)
        );
        
END rtl;