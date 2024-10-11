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


module fetch #(
    parameter ADDR_WIDTH = 32,
    parameter INSTR_WIDTH = 32,
    parameter IM_SIZE = 2048,  // 2KB instruction memory
    parameter DELAY_FETCH = 1  // 1ns delay for fetch
)(
    input wire clk,
    input wire reset,
    input wire [ADDR_WIDTH-1:0] branch_target,
    input wire branch_taken,
    output reg [INSTR_WIDTH-1:0] instruction,
    output reg [ADDR_WIDTH-1:0] pc_next
);

    reg [ADDR_WIDTH-1:0] pc;
    reg [INSTR_WIDTH-1:0] instruction_memory [0:IM_SIZE/4-1];  // Word-addressable

    // Initialize instruction memory
    initial begin
        $readmemh("instruction_memory.mem", instruction_memory);
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
        end else begin
            pc <= pc_next;
        end
    end

    always @(*) begin
        #DELAY_FETCH;  // Fetch delay
        instruction = instruction_memory[pc[ADDR_WIDTH-1:2]];  // Word-aligned access
        pc_next = branch_taken ? branch_target : pc + 4;
    end

endmodule
