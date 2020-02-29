-------------------------------------------------------------------------
-- David Tassoni
-- 
-- Lab 2
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY lab2 is
  port (
  
    ----- CLOCK -----
    CLOCK_50  : in std_logic;

    ----- SEG7_DISPLAY -----
    HEX0 : out std_logic_vector(6 downto 0);

    ----- KEYS -----
    KEY : in std_logic_vector(3 downto 0);

    ----- LED -----
    LEDR : out  std_logic_vector(9 downto 0);

    ----- SWITCHES -----
    SW : in  std_logic_vector(9 downto 0)
 
  );
end entity lab2;

architecture lab2_arch of lab2 is
  -- signal declarations
  signal cntr    : std_logic_vector(25 downto 0);
  signal reset_n : std_logic;
  signal key0_d1 : std_logic;
  signal key0_d2 : std_logic;
  signal key0_d3 : std_logic;
  -- end signal declarations --
  
  component nios_system is
    port (
			clk_clk            : in  std_logic                    := 'X';             -- clk
			reset_reset_n      : in  std_logic                    := 'X';             -- reset_n
			switches_export    : in  std_logic_vector(7 downto 0) := (others => 'X'); -- export
			pushbuttons_export : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
			hex0_export        : out std_logic_vector(6 downto 0)                     -- export
		);
  end component nios_system;
  
begin
  
   ----- Syncronize the reset
  synchReset_proc : process (CLOCK_50) begin
    if (rising_edge(CLOCK_50)) then
      key0_d1 <= KEY(0);
      key0_d2 <= key0_d1;
      key0_d3 <= key0_d2;
    end if;
  end process synchReset_proc;
  reset_n <= key0_d3;
  
  --- heartbeat counter -------- to check for proper loading of the program
  counter_proc : process (CLOCK_50) begin
    if (rising_edge(CLOCK_50)) then
      if (reset_n = '0') then
        cntr <= "00" & x"000000";
      else
        cntr <= cntr + ("00" & x"000001");
      end if;
    end if;
  end process counter_proc;
  
  LEDR(9) <= cntr(24); -- LED 8 will blink to check proper loading of the program

  ----- Instantiate the nios processor
  u0 : component nios_system
		port map (
			clk_clk            => CLOCK_50,          -- clk.clk
			reset_reset_n      => reset_n,           -- reset.reset_n
			switches_export    => SW   (7 downto 0), -- switches.export
			pushbuttons_export => KEY  (3 downto 0), -- pushbuttons.export
			hex0_export        => HEX0 (6 downto 0)  -- hex0.export
		);

end architecture lab2_arch;
