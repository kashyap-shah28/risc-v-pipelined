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


module memory #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_SIZE = 8192,  // 8KB data memory
    parameter DELAY_MEM = 5     // 5ns delay for memory access
)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] address,
    input wire [DATA_WIDTH-1:0] write_data,
    input wire mem_read,
    input wire mem_write,
    output reg [DATA_WIDTH-1:0] read_data
);

    reg [7:0] data_memory [0:MEM_SIZE-1];  // Byte-addressable memory

    // Initialize data memory
    initial begin
        $readmemh("data_memory.mem", data_memory);
    end

    always @(posedge clk) begin
        if (mem_write) begin
            #DELAY_MEM;
            {data_memory[address], data_memory[address+1], data_memory[address+2], data_memory[address+3]} <= write_data;
        end
    end

    always @(*) begin
        if (mem_read) begin
            #DELAY_MEM;
            read_data = {data_memory[address], data_memory[address+1], data_memory[address+2], data_memory[address+3]};
        end else begin
            read_data = {DATA_WIDTH{1'b0}};
        end
    end

endmodule

