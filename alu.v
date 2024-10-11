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


module alu #(
    parameter DATA_WIDTH = 32,
    parameter DELAY_ALU = 3,  // 3ns delay for basic ALU operations
    parameter DELAY_MUL = 8,  // 8ns delay for multiplication
    parameter DELAY_DIV = 10  // 10ns delay for division
)(
    input wire [DATA_WIDTH-1:0] operand1,
    input wire [DATA_WIDTH-1:0] operand2,
    input wire [3:0] alu_op,
    input wire [1:0] forward_a,
    input wire [1:0] forward_b,
    input wire [DATA_WIDTH-1:0] ex_mem_result,
    input wire [DATA_WIDTH-1:0] mem_wb_result,
    output reg [DATA_WIDTH-1:0] result,
    output reg zero_flag
);

    wire [DATA_WIDTH-1:0] alu_input1, alu_input2;

    // Input multiplexers for forwarding
    assign alu_input1 = (forward_a == 2'b00) ? operand1 :
                        (forward_a == 2'b10) ? ex_mem_result : mem_wb_result;
    
    assign alu_input2 = (forward_b == 2'b00) ? operand2 :
                        (forward_b == 2'b10) ? ex_mem_result : mem_wb_result;

    // Carry Lookahead Adder (4-bit)
    function [4:0] cla_4bit;
        input [3:0] a, b;
        input cin;
        reg [3:0] g, p, c;
        reg [3:0] sum;
        begin
            g = a & b;
            p = a ^ b;
            c[0] = cin;
            c[1] = g[0] | (p[0] & c[0]);
            c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
            c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
            sum = p ^ c;
            cla_4bit = {c[3], sum};
        end
    endfunction

    // 32-bit Carry Lookahead Adder
    function [32:0] cla_32bit;
        input [31:0] a, b;
        input cin;
        reg [7:0] carry;
        reg [31:0] sum;
        integer i;
        begin
            {carry[0], sum[3:0]} = cla_4bit(a[3:0], b[3:0], cin);
            for (i = 1; i < 8; i = i + 1) begin
                {carry[i], sum[4*i+3:4*i]} = cla_4bit(a[4*i+3:4*i], b[4*i+3:4*i], carry[i-1]);
            end
            cla_32bit = {carry[7], sum};
        end
    endfunction

    // Booth's Multiplication (8-bit)
    function [15:0] booths_multiply;
        input [7:0] multiplier, multiplicand;
        reg [16:0] product;
        reg [7:0] neg_multiplicand;
        integer i;
        begin
            product = {8'b0, multiplier, 1'b0};
            neg_multiplicand = -multiplicand;
            
            for (i = 0; i < 8; i = i + 1) begin
                case (product[1:0])
                    2'b01: product[16:8] = product[16:8] + multiplicand;
                    2'b10: product[16:8] = product[16:8] + neg_multiplicand;
                    default: ; // Do nothing for 00 or 11
                endcase
                product = product >> 1;
                product[16] = product[15];
            end
            booths_multiply = product[16:1];
        end
    endfunction

    // Simple Division (8-bit)
    function [15:0] simple_divide;
        input [7:0] dividend, divisor;
        reg [7:0] quotient, remainder;
        reg [7:0] temp_dividend;
        integer i;
        begin
            quotient = 0;
            remainder = 0;
            for (i = 7; i >= 0; i = i - 1) begin
                remainder = remainder << 1;
                remainder[0] = dividend[i];
                if (remainder >= divisor) begin
                    remainder = remainder - divisor;
                    quotient[i] = 1;
                end
            end
            simple_divide = {quotient, remainder};
        end
    endfunction

    always @(*) begin
        case (alu_op)
            4'b0000: begin // ADD
                #DELAY_ALU;
                {result, zero_flag} = cla_32bit(alu_input1, alu_input2, 1'b0);
            end
            4'b0001: begin // SUB
                #DELAY_ALU;
                {result, zero_flag} = cla_32bit(alu_input1, ~alu_input2, 1'b1);
            end
            4'b0010: begin // AND
                #DELAY_ALU;
                result = alu_input1 & alu_input2;
                zero_flag = (result == 0);
            end
            4'b0011: begin // OR
                #DELAY_ALU;
                result = alu_input1 | alu_input2;
                zero_flag = (result == 0);
            end
            4'b0100: begin // XOR
                #DELAY_ALU;
                result = alu_input1 ^ alu_input2;
                zero_flag = (result == 0);
            end
            4'b0101: begin // SLL
                #DELAY_ALU;
                result = alu_input1 << alu_input2[4:0];
                zero_flag = (result == 0);
            end
            4'b0110: begin // SRL
                #DELAY_ALU;
                result = alu_input1 >> alu_input2[4:0];
                zero_flag = (result == 0);
            end
            4'b0111: begin // SRA
                #DELAY_ALU;
                result = $signed(alu_input1) >>> alu_input2[4:0];
                zero_flag = (result == 0);
            end
            4'b1000: begin // MUL (8-bit)
                #DELAY_MUL;
                result = {{16{1'b0}}, booths_multiply(alu_input1[7:0], alu_input2[7:0])};
                zero_flag = (result == 0);
            end
            4'b1001: begin // DIV (8-bit)
                #DELAY_DIV;
                result = {{16{1'b0}}, simple_divide(alu_input1[7:0], alu_input2[7:0])};
                zero_flag = (result == 0);
            end
            default: begin
                #DELAY_ALU;
                result = {DATA_WIDTH{1'b0}};
                zero_flag = 1'b1;
            end
        endcase
    end

endmodule

