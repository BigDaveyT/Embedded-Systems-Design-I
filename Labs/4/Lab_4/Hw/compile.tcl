# Athaxes Alexandre
# Quartus Prime compile script for DE1-SoC board

# 1] name your project here
set project_name "Lab_4_Servo_Controller"

file delete -force project
file delete -force output_files
file mkdir project
cd project
load_package flow
project_new $project_name
set_global_assignment -name FAMILY Cyclone
set_global_assignment -name DEVICE 5CSEMA5F31C6 
set_global_assignment -name TOP_LEVEL_ENTITY "Lab_4_Servo_Controller_Top"
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY ../output_files

# 2] include your relative path files here
set_global_assignment -name VHDL_FILE ../../Src/Lab_4_RAM.vhd
set_global_assignment -name VHDL_FILE ../../Src/Lab_4_Servo_Controller.vhd
set_global_assignment -name VHDL_FILE ../../Src/Lab_4_Servo_Controller_Top.vhd

# 3] assign pin assignments for I/O
set_location_assignment PIN_AF14 -to CLOCK_50

set_location_assignment PIN_AA14 -to KEY[0]
set_location_assignment PIN_AA15 -to KEY[1]
set_location_assignment PIN_W15 -to KEY[2]
set_location_assignment PIN_Y16 -to KEY[3]

set_location_assignment PIN_V16 -to LEDR[0]
set_location_assignment PIN_W16 -to LEDR[1]
set_location_assignment PIN_V17 -to LEDR[2]
set_location_assignment PIN_V18 -to LEDR[3]
set_location_assignment PIN_W17 -to LEDR[4]
set_location_assignment PIN_W19 -to LEDR[5]
set_location_assignment PIN_Y19 -to LEDR[6]
set_location_assignment PIN_W20 -to LEDR[7]
set_location_assignment PIN_W21 -to LEDR[8]
set_location_assignment PIN_Y21 -to LEDR[9]

set_location_assignment PIN_AC18 -to GPIO_0[0]
set_location_assignment PIN_AH18 -to GPIO_0[10]
set_location_assignment PIN_AH17 -to GPIO_0[11]
set_location_assignment PIN_AG16 -to GPIO_0[12]
set_location_assignment PIN_AE16 -to GPIO_0[13]
set_location_assignment PIN_AF16 -to GPIO_0[14]
set_location_assignment PIN_AG17 -to GPIO_0[15]
set_location_assignment PIN_AA18 -to GPIO_0[16]
set_location_assignment PIN_AA19 -to GPIO_0[17]
set_location_assignment PIN_AE17 -to GPIO_0[18]
set_location_assignment PIN_AC20 -to GPIO_0[19]
set_location_assignment PIN_Y17 -to GPIO_0[1]
set_location_assignment PIN_AH19 -to GPIO_0[20]
set_location_assignment PIN_AJ20 -to GPIO_0[21]
set_location_assignment PIN_AH20 -to GPIO_0[22]
set_location_assignment PIN_AK21 -to GPIO_0[23]
set_location_assignment PIN_AD19 -to GPIO_0[24]
set_location_assignment PIN_AD20 -to GPIO_0[25]
set_location_assignment PIN_AE18 -to GPIO_0[26]
set_location_assignment PIN_AE19 -to GPIO_0[27]
set_location_assignment PIN_AF20 -to GPIO_0[28]
set_location_assignment PIN_AF21 -to GPIO_0[29]
set_location_assignment PIN_AD17 -to GPIO_0[2]
set_location_assignment PIN_AF19 -to GPIO_0[30]
set_location_assignment PIN_AG21 -to GPIO_0[31]
set_location_assignment PIN_AF18 -to GPIO_0[32]
set_location_assignment PIN_AG20 -to GPIO_0[33]
set_location_assignment PIN_AG18 -to GPIO_0[34]
set_location_assignment PIN_AJ21 -to GPIO_0[35]
set_location_assignment PIN_Y18 -to GPIO_0[3]
set_location_assignment PIN_AK16 -to GPIO_0[4]
set_location_assignment PIN_AK18 -to GPIO_0[5]
set_location_assignment PIN_AK19 -to GPIO_0[6]
set_location_assignment PIN_AJ19 -to GPIO_0[7]
set_location_assignment PIN_AJ17 -to GPIO_0[8]
set_location_assignment PIN_AJ16 -to GPIO_0[9]

execute_flow -compile

project_close