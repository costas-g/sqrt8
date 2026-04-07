## Primary clock definition (100 MHz)
#create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} -add [get_ports CLK]

## Primary clock definition (200 MHz)
#create_clock -period 5.000 -name sys_clk -waveform {0.000 2.500} -add [get_ports CLK]

## Primary clock definition (250 MHz)
#create_clock -period 4.000 -name sys_clk -waveform {0.000 2.000} -add [get_ports CLK]

## Primary clock definition (285 MHz)
#create_clock -period 3.500 -name sys_clk -waveform {0.000 1.750} -add [get_ports CLK]

# Primary clock definition (300 MHz)
create_clock -period 3.330 -name sys_clk -waveform {0.000 1.665} -add [get_ports CLK]

## Primary clock definition (333 MHz)
#create_clock -period 3.000 -name sys_clk -waveform {0.000 1.500} -add [get_ports CLK]

## Primary clock definition (400 MHz)
#create_clock -period 2.500 -name sys_clk -waveform {0.000 1.250} -add [get_ports CLK]