module branch_predictor #(
    parameter ADDR_WIDTH = 32,
    parameter BTB_SIZE = 64
)(
    input wire clk,
    input wire reset,
    input wire [ADDR_WIDTH-1:0] pc,
    input wire branch_outcome,
    input wire branch_taken,
    output wire predicted_taken
);

    reg [1:0] prediction_bits [0:BTB_SIZE-1];
    reg [ADDR_WIDTH-1:0] btb [0:BTB_SIZE-1];

    wire [5:0] index = pc[7:2];  // Use 6 bits of PC as index

    assign predicted_taken = prediction_bits[index][1];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < BTB_SIZE; i = i + 1) begin
                prediction_bits[i] <= 2'b01;  // Initialize to Weakly Not Taken
                btb[i] <= 0;
            end
        end else if (branch_outcome) begin
            if (branch_taken && prediction_bits[index] != 2'b11)
                prediction_bits[index] <= prediction_bits[index] + 1;
            else if (!branch_taken && prediction_bits[index] != 2'b00)
                prediction_bits[index] <= prediction_bits[index] - 1;
            
            btb[index] <= pc;  // Update BTB entry
        end
    end

endmodule