Automated RTL-to-Synthesis Flow & 8-bit ALU IP Design
📌 Executive Summary

This project demonstrates a fully automated Electronic Design Automation (EDA) pipeline for Digital IC design, bridging the gap between Front-End RTL coding and Back-End physical awareness.

It features a custom synchronous 8-bit Arithmetic Logic Unit (ALU) written in Verilog, which is verified, synthesized, and analyzed for timing closure using an automated Python workflow.
The design is mapped to the open-source SkyWater 130 nm PDK.

By treating hardware development like software DevOps, this project reduces full-flow regression time
(Simulation → Synthesis → STA) to under 2 seconds, enabling rapid Design Space Exploration and PPA extraction.

🛠️ System Architecture (Device Under Test)

The Device Under Test (DUT) is a synchronous 8-bit ALU supporting 16 operations with registered outputs and status flags.

Key Specifications

Data Width: 8-bit inputs/outputs

Control: Active-low async reset (rst_n), synchronous enable (en)

Instruction Set: ADD, SUB, MUL, AND, OR, XOR, NOT, shifts, comparisons

Status Flags: Zero (Z), Negative (N), Carry (C), Overflow (V)
