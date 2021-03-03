	component nios_system is
		port (
			clk_clk                   : in  std_logic                    := 'X';             -- clk
			leds_export_export        : out std_logic_vector(7 downto 0);                    -- export
			pushbuttons_export_export : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
			reset_reset_n             : in  std_logic                    := 'X'              -- reset_n
		);
	end component nios_system;

	u0 : component nios_system
		port map (
			clk_clk                   => CONNECTED_TO_clk_clk,                   --                clk.clk
			leds_export_export        => CONNECTED_TO_leds_export_export,        --        leds_export.export
			pushbuttons_export_export => CONNECTED_TO_pushbuttons_export_export, -- pushbuttons_export.export
			reset_reset_n             => CONNECTED_TO_reset_reset_n              --              reset.reset_n
		);

