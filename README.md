## risc-v-pipelined
Pipelined RISC-V processor with subset of RV32I instruction and 8 bit multipication and division instruction implemented.
# Overview
This project implements a non-pipelined 32-bit RISC-V processor supporting a subset of RV32I instructions, along with 8-bit multiplication and division capabilities. The processor is designed in Verilog HDL and simulated using Xilinx Vivado. The design is modular, with each stage of the processor split into separate Verilog files to ensure clarity and scalability for future phases (pipelining, hazard detection, cache integration).

# Features
RV32I Subset Instructions:
Arithmetic & Logical: add, sub, and, or, xor, not, sll, srl, sra

-Immediate Instructions: addi, subi, andi, ori, xori, slli, srli, srai

-Memory Operations: lw, sw

-Control Flow: beq, bge, blt, jal

-Multiply and Divide Support: 8-bit using Booth's Algorithm for multiplication and a simple division algorithm.

-32-bit Data Path for general instructions.

-2KB Instruction Memory and 8KB Data Memory, both preloaded from external files.

-1 GHz Clock Speed (1ns cycle period).

