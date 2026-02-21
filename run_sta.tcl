# Script: run_sta.tcl
# Purpose: Static Timing Analysis (STA) with OpenSTA
# Features: Setup (Max) & Hold (Min) Analysis + I/O Constraints

# 1. Load the Library
read_liberty sky130.lib

# 2. Load the Synthesized Netlist
read_verilog alu_netlist.v
link_design alu

# 3. Define Clock Constraint
if {[info exists ::env(CLK_PERIOD)]} {
    set clk_period $::env(CLK_PERIOD)
} else {
    set clk_period 10.0
    puts "Warning: CLK_PERIOD not set, defaulting to 10.0ns"
}

create_clock -name clk -period $clk_period {clk}

# 4. I/O constraints and Load modelling
# A. Input Delay: Data takes 2ns to arrive from the external CPU
set_input_delay -clock clk 2.0 [get_ports {a[*] b[*] op[*] rst_n en}]

# B. Output Delay: Data must be ready 2ns before the next chip needs it
set_output_delay -clock clk 2.0 [get_ports {out[*] flags[*]}]

# C. Driving Cell: Simulate a real Sky130 buffer driving the inputs (Realistic Sizing)
#    (This tells the tool the inputs aren't infinitely strong)
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 [all_inputs]

# D. Load Capacitance: Simulate a real wire load (0.05pF) on the outputs
#    (This tells the tool the outputs are driving actual wires)
set_load 0.05 [all_outputs]

# E. False Path: Don't check timing for the Reset signal (it's asynchronous/slow)
set_false_path -from [get_ports rst_n]

# 5. Generate Reports
# CHECK 1: SETUP (Max Delay) - Ensures we meet the frequency target
report_checks -path_delay max -format full_clock_expanded > timing_setup.rpt

# CHECK 2: HOLD (Min Delay) - Ensures no race conditions (Fast path check)
report_checks -path_delay min -format full_clock_expanded > timing_hold.rpt

# CHECK 3: Violations - List any failing paths
report_checks -slack_max 0.0 > violations.rpt

exit