# Create a clock constraint for the 1 MHz clock
create_clock -name clk_1MHz -period 1 [get_ports clk_1MHz]

# Set clock uncertainty for setup and hold checks
set_clock_uncertainty -setup 0.5 [get_clocks clk_1MHz]
set_clock_uncertainty -hold 0.3 [get_clocks clk_1MHz]

# Define clock groups (if necessary)
# For example, if you have other clocks:
# set_clock_groups -asynchronous -group [get_clocks clk_1MHz] -group [get_clocks other_clock]

# Constraints for input delay (optional)
# set_input_delay -clock [get_clocks clk_1MHz] 1.0 [all_inputs]

# Constraints for output delay (optional)
# set_output_delay -clock [get_clocks clk_1MHz] 1.0 [all_outputs]
