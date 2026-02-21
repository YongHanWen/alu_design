# Script: run_synth.tcl
# Purpose: Synthesis using Yosys

# 1. (REMOVED) read_liberty is not needed here for this Yosys version.

# 2. Read the Design
read_verilog alu.v

# 3. Synthesize to Generic Gates
synth -top alu

# 4. Map to Sky130 Standard Cells
# We pass the library explicitly here instead
dfflibmap -liberty sky130.lib
abc -liberty sky130.lib

# 5. Output the Netlist
write_verilog alu_netlist.v

# 6. Print Stats
stat -liberty sky130.lib

# 7. Generate visual schematic of the synthesized gates
show -format svg -prefix alu_schematic alu