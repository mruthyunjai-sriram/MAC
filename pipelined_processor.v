// Pipelined MAC Unit
module PipelinedMAC (
    input [7:0] weights,  // 8-bit weights (A)
    input [7:0] activations, // 8-bit activations (B)
    input clk,             // Clock signal
    input reset,           // Reset signal
    output reg [15:0] result // Final accumulated result
);

    // Internal signals for pipeline stages
    reg [7:0] stage1_encoded_weights;
    reg [7:0] stage1_weights;
    reg [7:0] stage1_activations;

    reg [15:0] stage2_shifted_value;
    reg [7:0] stage2_encoded_weights;

    reg [15:0] stage3_accumulator;

    integer i;
    integer shift_amount;

    // Stage 1: Encode Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stage1_encoded_weights <= 8'b0;
            stage1_weights <= 8'b0;
            stage1_activations <= 8'b0;
        end else begin
            stage1_encoded_weights <= 8'b0; // Clear encoded weights
            for (i = 0; i < 8; i = i + 1) begin
                if (weights[i] == 1'b1 && stage1_encoded_weights == 8'b0) begin
                    stage1_encoded_weights <= 8'b1 << i; // Encode position of the first '1'
                end
            end
            stage1_weights <= weights;
            stage1_activations <= activations;
        end
    end

    // Stage 2: Shift Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stage2_shifted_value <= 16'b0;
            stage2_encoded_weights <= 8'b0;
        end else begin
            stage2_encoded_weights <= stage1_encoded_weights;
            shift_amount = 0;
            for (i = 0; i < 8; i = i + 1) begin
                if (stage1_encoded_weights[i] == 1'b1) begin
                    shift_amount = i;
                end
            end
            stage2_shifted_value <= stage1_activations << shift_amount; // Shift activations
        end
    end

    // Stage 3: Accumulate Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stage3_accumulator <= 16'b0;
        end else begin
            stage3_accumulator <= stage3_accumulator + stage2_shifted_value;
        end
    end

    // Assign final result
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 16'b0;
        end else begin
            result <= stage3_accumulator;
        end
    end

endmodule