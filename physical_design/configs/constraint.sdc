current_design dot_product_4lane

create_clock -name core_clock -period 2.0 [get_ports clk]
set_clock_uncertainty 0.1 [get_clocks core_clock]

# Input timing assumptions
set_input_delay -max 1.0 -clock core_clock [get_ports {a* b* valid_in rst}]
set_input_delay -min 0.3 -clock core_clock [get_ports {a* b* valid_in rst}]

# Output timing assumptions
set_output_delay -max 1.0 -clock core_clock [get_ports {y* valid_out}]
set_output_delay -min 0.0 -clock core_clock [get_ports {y* valid_out}]

set_input_transition 0.1 [get_ports {a* b* valid_in rst}]
set_load 5.0 [get_ports {y* valid_out}]
