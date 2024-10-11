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

module pipelined_datapath #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5
)(
    input wire clk,
    input wire reset
);

    // Pipeline stage registers
    reg [ADDR_WIDTH-1:0] IF_ID_PC, ID_EX_PC;
    reg [INSTR_WIDTH-1:0] IF_ID_Instruction;
    reg [DATA_WIDTH-1:0] ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_Imm;
    reg [REG_ADDR_WIDTH-1:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;
    reg [3:0] ID_EX_ALUOp;
    reg ID_EX_ALUSrc, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_RegWrite, ID_EX_MemtoReg, ID_EX_Branch;

    reg [DATA_WIDTH-1:0] EX_MEM_ALUResult, EX_MEM_WriteData;
    reg [REG_ADDR_WIDTH-1:0] EX_MEM_Rd;
    reg EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_RegWrite, EX_MEM_MemtoReg;
    reg EX_MEM_Zero;
    reg [ADDR_WIDTH-1:0] EX_MEM_BranchTarget;

    reg [DATA_WIDTH-1:0] MEM_WB_ALUResult, MEM_WB_ReadData;
    reg [REG_ADDR_WIDTH-1:0] MEM_WB_Rd;
    reg MEM_WB_RegWrite, MEM_WB_MemtoReg;

    // Wires for connecting modules
    wire [ADDR_WIDTH-1:0] pc, pc_next, branch_target;
    wire [INSTR_WIDTH-1:0] instruction;
    wire [DATA_WIDTH-1:0] read_data1, read_data2, imm, alu_result, mem_read_data, write_data;
    wire [3:0] alu_op;
    wire [REG_ADDR_WIDTH-1:0] rs1, rs2, rd;
    wire mem_read, mem_write, alu_src, reg_write, mem_to_reg, branch, zero;

    // New wires for forwarding and branch prediction
    wire [1:0] forward_a, forward_b;
    wire predicted_taken, branch_outcome;
    wire flush;

    // Hazard detection unit
    wire stall;
    hazard_detection_unit hdu (
        .ID_EX_MemRead(ID_EX_MemRead),
        .ID_EX_Rd(ID_EX_Rd),
        .IF_ID_Rs1(IF_ID_Instruction[19:15]),
        .IF_ID_Rs2(IF_ID_Instruction[24:20]),
        .stall(stall)
    );

    // Forwarding unit
    forwarding_unit forwarding (
        .ID_EX_Rs1(ID_EX_Rs1),
        .ID_EX_Rs2(ID_EX_Rs2),
        .EX_MEM_Rd(EX_MEM_Rd),
        .MEM_WB_Rd(MEM_WB_Rd),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .ForwardA(forward_a),
        .ForwardB(forward_b)
    );

    // Branch predictor
    branch_predictor bp (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .branch_outcome(branch_outcome),
        .branch_taken(EX_MEM_Zero & EX_MEM_Branch),
        .predicted_taken(predicted_taken)
    );

    // Fetch stage
    fetch fetch_stage (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .branch_target(EX_MEM_BranchTarget),
        .branch_taken(EX_MEM_Zero & EX_MEM_Branch),
        .predicted_taken(predicted_taken),
        .pc(pc),
        .pc_next(pc_next),
        .instruction(instruction)
    );

    // IF/ID Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            IF_ID_PC <= 0;
            IF_ID_Instruction <= 0;
        end else if (!stall) begin
            IF_ID_PC <= pc;
            IF_ID_Instruction <= instruction;
        end
    end

    // Decode stage
    decode decode_stage (
        .clk(clk),
        .reset(reset),
        .instruction(IF_ID_Instruction),
        .write_data(write_data),
        .write_reg(MEM_WB_Rd),
        .reg_write_en(MEM_WB_RegWrite),
        .rs1_data(read_data1),
        .rs2_data(read_data2),
        .imm(imm),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );

    // ID/EX Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            ID_EX_PC <= 0;
            ID_EX_ReadData1 <= 0;
            ID_EX_ReadData2 <= 0;
            ID_EX_Imm <= 0;
            ID_EX_Rs1 <= 0;
            ID_EX_Rs2 <= 0;
            ID_EX_Rd <= 0;
            ID_EX_ALUOp <= 0;
            ID_EX_ALUSrc <= 0;
            ID_EX_MemRead <= 0;
            ID_EX_MemWrite <= 0;
            ID_EX_RegWrite <= 0;
            ID_EX_MemtoReg <= 0;
            ID_EX_Branch <= 0;
        end else if (!stall) begin
            ID_EX_PC <= IF_ID_PC;
            ID_EX_ReadData1 <= read_data1;
            ID_EX_ReadData2 <= read_data2;
            ID_EX_Imm <= imm;
            ID_EX_Rs1 <= rs1;
            ID_EX_Rs2 <= rs2;
            ID_EX_Rd <= rd;
            ID_EX_ALUOp <= alu_op;
            ID_EX_ALUSrc <= alu_src;
            ID_EX_MemRead <= mem_read;
            ID_EX_MemWrite <= mem_write;
            ID_EX_RegWrite <= reg_write;
            ID_EX_MemtoReg <= mem_to_reg;
            ID_EX_Branch <= branch;
        end
    end

    // Execute stage (ALU)
    alu execute_stage (
        .operand1(ID_EX_ReadData1),
        .operand2(ID_EX_ALUSrc ? ID_EX_Imm : ID_EX_ReadData2),
        .alu_op(ID_EX_ALUOp),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .ex_mem_result(EX_MEM_ALUResult),
        .mem_wb_result(write_data),
        .result(alu_result),
        .zero_flag(zero)
    );

    // EX/MEM Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_ALUResult <= 0;
            EX_MEM_WriteData <= 0;
            EX_MEM_Rd <= 0;
            EX_MEM_MemRead <= 0;
            EX_MEM_MemWrite <= 0;
            EX_MEM_RegWrite <= 0;
            EX_MEM_MemtoReg <= 0;
            EX_MEM_Zero <= 0;
            EX_MEM_BranchTarget <= 0;
        end else begin
            EX_MEM_ALUResult <= alu_result;
            EX_MEM_WriteData <= ID_EX_ALUSrc ? ID_EX_Imm : ID_EX_ReadData2;
            EX_MEM_Rd <= ID_EX_Rd;
            EX_MEM_MemRead <= ID_EX_MemRead;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_MemtoReg <= ID_EX_MemtoReg;
            EX_MEM_Zero <= zero;
            EX_MEM_BranchTarget <= ID_EX_PC + ID_EX_Imm;
        end
    end

    // Memory stage
    memory memory_stage (
        .clk(clk),
        .address(EX_MEM_ALUResult),
        .write_data(EX_MEM_WriteData),
        .mem_read(EX_MEM_MemRead),
        .mem_write(EX_MEM_MemWrite),
        .read_data(mem_read_data)
    );

    // MEM/WB Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_ALUResult <= 0;
            MEM_WB_ReadData <= 0;
            MEM_WB_Rd <= 0;
            MEM_WB_RegWrite <= 0;
            MEM_WB_MemtoReg <= 0;
        end else begin
            MEM_WB_ALUResult <= EX_MEM_ALUResult;
            MEM_WB_ReadData <= mem_read_data;
            MEM_WB_Rd <= EX_MEM_Rd;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
        end
    end

    // Writeback stage
    assign write_data = MEM_WB_MemtoReg ? MEM_WB_ReadData : MEM_WB_ALUResult;

    // Branch logic
    assign branch_outcome = ID_EX_Branch & zero;
    assign flush = branch_outcome != predicted_taken;

    // Update branch predictor
    always @(posedge clk) begin
        if (ID_EX_Branch)
            bp.branch_outcome <= branch_outcome;
    end

endmodule
