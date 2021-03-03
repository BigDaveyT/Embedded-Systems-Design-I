onerror {resume}
radix define radix_ssd {
    "7'b1000000" "0" -color "pink",
    "7'b1111001" "1" -color "pink",
    "7'b0100100" "2" -color "pink",
    "7'b0110000" "3" -color "pink",
    "7'b0011001" "4" -color "pink",
    "7'b0010010" "5" -color "pink",
    "7'b0000010" "6" -color "pink",
    "7'b1111000" "7" -color "pink",
    "7'b0000000" "8" -color "pink",
    "7'b0010000" "9" -color "pink",
    "7'b0001000" "A" -color "pink",
    "7'b0000011" "B" -color "pink",
    "7'b1000110" "C" -color "pink",
    "7'b0100001" "D" -color "pink",
    "7'b0000110" "E" -color "pink",
    "7'b0001110" "F" -color "pink",
    "7'b0111111" "dash" -color "pink",
    "7'b1111111" "blank" -color "pink",
    -default hexadecimal
}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group UUT /lab_4_servo_controller_tb/UUT/clk
add wave -noupdate -expand -group UUT /lab_4_servo_controller_tb/UUT/reset_n
add wave -noupdate -expand -group UUT /lab_4_servo_controller_tb/UUT/write
add wave -noupdate -expand -group UUT -radix decimal /lab_4_servo_controller_tb/UUT/writedata
add wave -noupdate -expand -group UUT -color {Medium Blue} -radix decimal /lab_4_servo_controller_tb/UUT/address
add wave -noupdate -expand -group UUT /lab_4_servo_controller_tb/UUT/wave_out
add wave -noupdate -expand -group UUT -color {Blue Violet} /lab_4_servo_controller_tb/UUT/irq
add wave -noupdate -expand -group UUT -color Cyan -radix decimal /lab_4_servo_controller_tb/UUT/Down_Angle_Count
add wave -noupdate -expand -group UUT -color Orange -radix decimal /lab_4_servo_controller_tb/UUT/Up_Angle_Count
add wave -noupdate -expand -group UUT -radix decimal /lab_4_servo_controller_tb/UUT/Default_Angle_Min
add wave -noupdate -expand -group UUT -radix decimal /lab_4_servo_controller_tb/UUT/Default_Angle_Max
add wave -noupdate -expand -group UUT -radix decimal /lab_4_servo_controller_tb/UUT/Current_Upper_Angle_Limit
add wave -noupdate -expand -group UUT -radix decimal /lab_4_servo_controller_tb/UUT/Current_Lower_Angle_Limit
add wave -noupdate -expand -group UUT -radix decimal /lab_4_servo_controller_tb/UUT/RAM_Angle_Limit
add wave -noupdate -expand -group UUT -radix decimal /lab_4_servo_controller_tb/UUT/Max_Count
add wave -noupdate -expand -group UUT -radix decimal /lab_4_servo_controller_tb/UUT/Period_Count
add wave -noupdate -expand -group UUT /lab_4_servo_controller_tb/UUT/current_state
add wave -noupdate -expand -group UUT /lab_4_servo_controller_tb/UUT/next_state
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16620603015 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 209
configure wave -valuecolwidth 71
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {735 ms}
