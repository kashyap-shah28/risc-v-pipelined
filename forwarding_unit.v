`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2024 22:32:00
// Design Name: 
// Module Name: forwarding_unit
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

module forwarding_unit #(
    parameter REG_ADDR_WIDTH = 5
)(
    input wire [REG_ADDR_WIDTH-1:0] ID_EX_Rs1,
    input wire [REG_ADDR_WIDTH-1:0] ID_EX_Rs2,
    input wire [REG_ADDR_WIDTH-1:0] EX_MEM_Rd,
    input wire [REG_ADDR_WIDTH-1:0] MEM_WB_Rd,
    input wire EX_MEM_RegWrite,
    input wire MEM_WB_RegWrite,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        // Forward A
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs1))
            ForwardA = 2'b10;
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rs1))
            ForwardA = 2'b01;
        else
            ForwardA = 2'b00;

        // Forward B
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs2))
            ForwardB = 2'b10;
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rs2))
            ForwardB = 2'b01;
        else
            ForwardB = 2'b00;
    end

endmodule