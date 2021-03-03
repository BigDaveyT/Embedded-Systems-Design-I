
module nios_system (
	clk_clk,
	reset_reset_n,
	ledr_export,
	avalon_bridge_acknowledge,
	avalon_bridge_irq,
	avalon_bridge_address,
	avalon_bridge_bus_enable,
	avalon_bridge_byte_enable,
	avalon_bridge_rw,
	avalon_bridge_write_data,
	avalon_bridge_read_data);	

	input		clk_clk;
	input		reset_reset_n;
	output	[9:0]	ledr_export;
	input		avalon_bridge_acknowledge;
	input		avalon_bridge_irq;
	output	[10:0]	avalon_bridge_address;
	output		avalon_bridge_bus_enable;
	output	[1:0]	avalon_bridge_byte_enable;
	output		avalon_bridge_rw;
	output	[15:0]	avalon_bridge_write_data;
	input	[15:0]	avalon_bridge_read_data;
endmodule
