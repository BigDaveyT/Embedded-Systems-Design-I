quartus_sh -t compile.tcl
pause
quartus_pgm --mode=JTAG -o P;output_files\Lab_4_Servo_Controller.sof@2
pause