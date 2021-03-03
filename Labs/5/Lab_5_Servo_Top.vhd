-------------------------------------------------------------------------
-- David Tassoni
-- Lab5_Servo_Top
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Lab_5_Servo_Top is
    port
    (
        ---- CLOCK ----
        CLOCK_50 : in std_logic;
        ---- SEG7 ----
        HEX5     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);  
        ---- KEY ----
        KEY      : in  std_logic_vector(3 downto 0);
        ---- SW ----
        SW       : in  std_logic_vector(7 downto 0);
        ---- GPIO_0, GPIO_0 connect to GPIO Default ----
        GPIO_0 : inout std_logic_vector(35 downto 0)
    );
End entity Lab_5_Servo_Top;

architecture arch of Lab_5_Servo_Top is

    -- signal Declarations
    signal reset_n    : std_logic;
    signal key_d1    : std_logic;
    signal key_d2    : std_logic;
    signal key_d3    : std_logic;

    component nios_system is
    port
    (
        clk_clk                                 : in  std_logic                    := 'X';             -- clk
        hex0_export                             : out std_logic_vector(6 downto 0);                    -- export
        hex1_export                             : out std_logic_vector(6 downto 0);                    -- export
        hex2_export                             : out std_logic_vector(6 downto 0);                    -- export
        hex3_export                             : out std_logic_vector(6 downto 0);                    -- export
        hex4_export                             : out std_logic_vector(6 downto 0);                    -- export
        hex5_export                             : out std_logic_vector(6 downto 0);                    -- export
        pushbuttons_export                      : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
        reset_reset_n                           : in  std_logic                    := 'X';             -- reset_n
        switches_export                         : in  std_logic_vector(7 downto 0) := (others => 'X'); -- export
        servo_controller_0_conduit_end_wave_out : out std_logic                                        -- wave_out
    );
    end component nios_system;
    
    BEGIN
        ----- Syncronize the reset
        synchReset_proc : process (CLOCK_50) begin
        if (rising_edge(CLOCK_50)) then
            key_d1 <= KEY(0);
            key_d2 <= key_d1;
            key_d3 <= key_d2;
        end if;
    end process synchReset_proc;
    
    reset_n <= key_d3;

    u0 : component nios_system
        port map
        (
            clk_clk                                 => CLOCK_50,   -- clk.clk
            hex0_export                             => HEX0,       -- hex0.export
            hex1_export                             => HEX1,       -- hex1.export
            hex2_export                             => HEX2,       -- hex2.export
            hex3_export                             => HEX3,       -- hex3.export
            hex4_export                             => HEX4,       -- hex4.export
            hex5_export                             => HEX5,       -- hex5.export
            pushbuttons_export                      => KEY,        -- pushbuttons.export
            reset_reset_n                           => reset_n,    -- reset.reset_n
            servo_controller_0_conduit_end_wave_out => GPIO_0(10), -- servo_controller_0_conduit_end.wave_out
            switches_export                         => SW          -- switches.export
        );
End architecture arch;
