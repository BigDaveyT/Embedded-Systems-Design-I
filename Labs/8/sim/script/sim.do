vlib work
vcom -2008 -work work ../../src/lowFilter.vhd
vcom -2008 -work work ../../Src/multiplier.vhd
vcom -2008 -work work ../src/filter_tb.vhd
vsim -voptargs=+acc Filter_tb
do wave.do
run 700 ms