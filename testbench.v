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

module testbench();
    reg clk;
    reg reset;

    // Instantiate the datapath
    datapath dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test stimulus
    initial begin
        reset = 1;
        #10 reset = 0;

        // Run for 100 cycles
        repeat(100) @(posedge clk);

        $finish;
    end

    // Monitoring
    initial begin
        $monitor("Time=%0t: PC=%h, Instruction=%h, ALU Result=%h, Memory Data=%h, Write Data=%h",
                 $time, dut.pc, dut.instruction, dut.alu_result, dut.mem_read_data, dut.write_data);
    end

endmodule

