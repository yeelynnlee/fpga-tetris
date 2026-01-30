`timescale 1ns / 1ps

module binary_to_bcd( input clk_in,
                      input [5:0] game_state,
                      input start,
                      input [23:0] binary_in,
                      output logic [31:0] bcd_out,
                      output logic busy
    );
    
    parameter RESET = 1;
    
    parameter IDLE = 0;
    parameter BUSY = 1;
    parameter DONE = 2;
    
    logic [1:0] state;
    logic [23:0] bin_in;
    logic [3:0] D_7, D_6, D_5, D_4, D_3, D_2, D_1, D_0;
    
    assign bcd_out = {D_7, D_6, D_5, D_4, D_3, D_2, D_1, D_0};
    
    always_ff @ (posedge clk_in) begin
        if (game_state == RESET) begin
            D_7 <= 0;
            D_6 <= 0;
            D_5 <= 0;
            D_4 <= 0;
            D_3 <= 0;
            D_2 <= 0;
            D_1 <= 0;
            D_0 <= 0;
            bin_in <= 0;
            state <= IDLE;
            busy <= 0;
        end else case(state)
            IDLE: begin
                if (start) begin
                    D_7 <= (binary_in >= 10_000_000) ? 0 : 4'hA;
                    D_6 <= (binary_in >= 1_000_000) ? 0 : 4'hA;
                    D_5 <= (binary_in >= 100_000) ? 0 : 4'hA;
                    D_4 <= (binary_in >= 10_000) ? 0 : 4'hA;
                    D_3 <= (binary_in >= 1_000) ? 0 : 4'hA;
                    D_2 <= (binary_in >= 100) ? 0 : 4'hA;
                    D_1 <= (binary_in >= 10) ? 0 : 4'hA;
                    D_0 <= 0;
                    bin_in <= binary_in;
                    state <= BUSY;
                    busy <= 1;
                end else state <= IDLE;
            end
            BUSY: begin
                if (bin_in >= 10_000_000) begin
                    bin_in <= bin_in - 10_000_000;
                    D_7 <= D_7 + 1;
                end else if (bin_in >= 1_000_000) begin
                    bin_in <= bin_in - 1_000_000;
                    D_6 <= D_6 + 1;
                end else if (bin_in >= 100_000) begin
                    bin_in <= bin_in - 100_000;
                    D_5 <= D_5 + 1;
                end else if (bin_in >= 10_000) begin
                    bin_in <= bin_in - 10_000;
                    D_4 <= D_4 + 1;
                end else if (bin_in >= 1_000) begin
                    bin_in <= bin_in - 1_000;
                    D_3 <= D_3 + 1;
                end else if (bin_in >= 100) begin
                    bin_in <= bin_in - 100;
                    D_2 <= D_2 + 1;
                end else if (bin_in >= 10) begin
                    bin_in <= bin_in - 10;
                    D_1 <= D_1 + 1;
                end else begin
                    D_0 <= bin_in;
                    state <= DONE;
                    busy <= 0;
                end
            end
            DONE: begin
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase                           
    end
    
endmodule
