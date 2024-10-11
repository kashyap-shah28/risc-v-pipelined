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



  module decode #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5,
    parameter NUM_REGS = 32,
    parameter DELAY_DECODE = 2  // 2ns delay for decode
)(
    input wire clk,
    input wire [INSTR_WIDTH-1:0] instruction,
    input wire [DATA_WIDTH-1:0] write_data,
    input wire [REG_ADDR_WIDTH-1:0] write_reg,
    input wire reg_write_en,
    output reg [DATA_WIDTH-1:0] rs1_data,
    output reg [DATA_WIDTH-1:0] rs2_data,
    output reg [DATA_WIDTH-1:0] imm,
    output reg [3:0] alu_op,
    output reg mem_read,
    output reg mem_write,
    output reg [1:0] wb_sel,
    output reg [REG_ADDR_WIDTH-1:0] rd
);

    reg [DATA_WIDTH-1:0] registers [0:NUM_REGS-1];
    // Initialize register file
    initial begin
        $readmemh("register_file.mem", registers);
    end
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [REG_ADDR_WIDTH-1:0] rs1, rs2;

    assign opcode = instruction[6:0];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // Register file read and write
    always @(posedge clk) begin
        if (reg_write_en && write_reg != 0) begin
            registers[write_reg] <= write_data;
        end
    end

    always @(*) begin
        #DELAY_DECODE;  // Decode delay
        rs1_data = (rs1 == 0) ? 0 : registers[rs1];
        rs2_data = (rs2 == 0) ? 0 : registers[rs2];

        // Immediate generation and instruction decoding
        case (opcode)
            7'b0110011: begin // R-type
                imm = 32'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                wb_sel = 2'b00; // ALU result
                case (funct3)
                    3'b000: alu_op = (funct7[5]) ? 4'b0001 : 4'b0000; // sub : add
                    3'b111: alu_op = 4'b0010; // and
                    3'b110: alu_op = 4'b0011; // or
                    3'b100: alu_op = 4'b0100; // xor
                    3'b001: alu_op = 4'b0101; // sll
                    3'b101: alu_op = (funct7[5]) ? 4'b0111 : 4'b0110; // sra : srl
                    default: alu_op = 4'b1111; // Invalid
                endcase
            end
            7'b0010011: begin // I-type ALU
                imm = {{20{instruction[31]}}, instruction[31:20]};
                mem_read = 1'b0;
                mem_write = 1'b0;
                wb_sel = 2'b00; // ALU result
                case (funct3)
                    3'b000: alu_op = 4'b0000; // addi
                    3'b111: alu_op = 4'b0010; // andi
                    3'b110: alu_op = 4'b0011; // ori
                    3'b100: alu_op = 4'b0100; // xori
                    3'b001: alu_op = 4'b0101; // slli
                    3'b101: alu_op = (funct7[5]) ? 4'b0111 : 4'b0110; // srai : srli
                    default: alu_op = 4'b1111; // Invalid
                endcase
            end
            7'b0000011: begin // Load
                imm = {{20{instruction[31]}}, instruction[31:20]};
                mem_read = 1'b1;
                mem_write = 1'b0;
                wb_sel = 2'b01; // Memory result
                alu_op = 4'b0000; // Add for address calculation
            end
            7'b0100011: begin // Store
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                mem_read = 1'b0;
                mem_write = 1'b1;
                wb_sel = 2'bxx; // Don't care
                alu_op = 4'b0000; // Add for address calculation
            end
            7'b1100011: begin // Branch
                imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                mem_read = 1'b0;
                mem_write = 1'b0;
                wb_sel = 2'bxx; // Don't care
                case (funct3)
                    3'b000: alu_op = 4'b1000; // beq
                    3'b101: alu_op = 4'b1001; // bge
                    3'b100: alu_op = 4'b1010; // blt
                    default: alu_op = 4'b1111; // Invalid
                endcase
            end
            7'b1101111: begin // JAL
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                mem_read = 1'b0;
                mem_write = 1'b0;
                wb_sel = 2'b10; // PC + 4
                alu_op = 4'b1011; // JAL
            end
            default: begin
                imm = 32'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                wb_sel = 2'bxx;
                alu_op = 4'b1111; // Invalid
            end
        endcase
    end

endmodule
