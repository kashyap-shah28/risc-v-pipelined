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


module hazard_detection_unit #(
    parameter REG_ADDR_WIDTH = 5
)(
    input wire ID_EX_MemRead,
    input wire [REG_ADDR_WIDTH-1:0] ID_EX_Rd,
    input wire [REG_ADDR_WIDTH-1:0] IF_ID_Rs1,
    input wire [REG_ADDR_WIDTH-1:0] IF_ID_Rs2,
    output reg stall
);

    always @(*) begin
        if (ID_EX_MemRead && 
            ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2))) begin
            stall = 1'b1;  // Stall the pipeline
        end else begin
            stall = 1'b0;  // No stall
        end
    end

endmodule

