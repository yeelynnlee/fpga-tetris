`timescale 1ns / 1ps

module debounce #(parameter NUM_CYCLES = 1485000)//10 ms 
                 (input clk_in,
                  input reset_in,
                  input noisy_in,
                  output logic clean_out);

    logic [20:0] count;
    logic new_input;

    always_ff @(posedge clk_in) begin
        if (reset_in) begin
            new_input <= noisy_in; 
            clean_out <= noisy_in; 
            count <= 0;
        end else if (noisy_in != new_input) begin
            new_input <= noisy_in;
            count <= 0;
        end else if (count == NUM_CYCLES)
            clean_out <= new_input;
        else count <= count + 1;
    end

endmodule
