vlib work
vcom -2008 -work work ../../Src/Lab_4_RAM.vhd
vcom -2008 -work work ../../Src/Lab_4_Servo_Controller.vhd
vcom -2008 -work work ../src/Lab_4_Servo_Controller_tb.vhd
vsim -voptargs=+acc Lab_4_Servo_Controller_tb
do wave.do
run 700 ms
