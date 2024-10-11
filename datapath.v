`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2024 18:46:42
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module datapath #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5
)(
    input wire clk,
    input wire reset
);

    // Interconnect wires
    wire [ADDR_WIDTH-1:0] pc, pc_next, branch_target;
    wire [INSTR_WIDTH-1:0] instruction;
    wire [DATA_WIDTH-1:0] rs1_data, rs2_data, imm, alu_result, mem_read_data, write_data;
    wire [3:0] alu_op;
    wire [1:0] wb_sel;
    wire [REG_ADDR_WIDTH-1:0] rd;
    wire mem_read, mem_write, branch_taken, zero_flag;

    // Fetch stage
    fetch fetch_stage (
        .clk(clk),
        .reset(reset),
        .branch_target(branch_target),
        .branch_taken(branch_taken),
        .instruction(instruction),
        .pc_next(pc_next)
    );

    // Decode stage
    decode decode_stage (
        .clk(clk),
        .instruction(instruction),
        .write_data(write_data),
        .write_reg(rd),
        .reg_write_en(1'b1), // Always enable write for simplicity
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .wb_sel(wb_sel),
        .rd(rd)
    );

    // Execute stage
    alu execute_stage (
        .operand1(rs1_data),
        .operand2(rs2_data),
        .alu_op(alu_op),
        .result(alu_result),
        .zero_flag(zero_flag)
    );

    // Memory stage
    memory memory_stage (
        .clk(clk),
        .address(alu_result),
        .write_data(rs2_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(mem_read_data)
    );

    // Writeback stage
    writeback writeback_stage (
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .pc_plus_4(pc_next),
        .wb_sel(wb_sel),
        .write_data(write_data)
    );

    // Branch logic
    assign branch_taken = (alu_op == 4'b1000 && zero_flag) || // BEQ
                          (alu_op == 4'b1001 && alu_result[0]) || // BGE
                          (alu_op == 4'b1010 && alu_result[0]) || // BLT
                          (alu_op == 4'b1011); // JAL
    assign branch_target = pc + imm;

endmodule

