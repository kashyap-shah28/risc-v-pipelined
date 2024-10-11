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


module writeback #(
    parameter DATA_WIDTH = 32,
    parameter DELAY_WB = 1  // 1ns delay for write back
)(
    input wire [DATA_WIDTH-1:0] alu_result,
    input wire [DATA_WIDTH-1:0] mem_data,
    input wire [DATA_WIDTH-1:0] pc_plus_4,
    input wire [1:0] wb_sel,
    output reg [DATA_WIDTH-1:0] write_data
);

    always @(*) begin
        #DELAY_WB;
        case (wb_sel)
            2'b00: write_data = alu_result;  // ALU result
            2'b01: write_data = mem_data;    // Memory data
            2'b10: write_data = pc_plus_4;   // PC + 4 (for JAL)
            default: write_data = {DATA_WIDTH{1'b0}};
        endcase
    end

endmodule

