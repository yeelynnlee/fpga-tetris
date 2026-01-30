`timescale 1ns / 1ps


module increment_bcd( input clk_in,
                      input [5:0] game_state,
                      input start,
                      input [31:0] bcd_in,
                      output logic [31:0] bcd_out,
                      output logic busy

    );
    
    parameter RESET = 1;
    
    parameter IDLE = 0;
    parameter INCREMENT = 1;
    parameter CONVERT_BCD = 2;
    parameter REMOVE_LEADING_ZEROES = 3;
    parameter DONE = 4;
    
    logic [2:0] state;
     
    logic [3:0] D_7, D_6, D_5, D_4, D_3, D_2, D_1, D_0;
    assign D_0 = bcd_out[3:0];
    assign D_1 = bcd_out[7:4];
    assign D_2 = bcd_out[11:8];
    assign D_3 = bcd_out[15:12];
    assign D_4 = bcd_out[19:16];
    assign D_5 = bcd_out[23:20];
    assign D_6 = bcd_out[27:24];
    assign D_7 = bcd_out[31:28];
    
    always_ff @ (posedge clk_in) begin
        if (game_state == RESET) begin
            bcd_out <= 0;
            state <= IDLE;
            busy <= 0;
        end else case(state)
            IDLE: begin
                if (start) begin
                    bcd_out[31:28] <= (bcd_in[31:28] == 4'hA) ? 0 : bcd_in[31:28];
                    bcd_out[27:24] <= (bcd_in[27:24] == 4'hA) ? 0 : bcd_in[27:24];
                    bcd_out[23:20] <= (bcd_in[23:20] == 4'hA) ? 0 : bcd_in[23:20];
                    bcd_out[19:16] <= (bcd_in[19:16] == 4'hA) ? 0 : bcd_in[19:16];
                    bcd_out[15:12] <= (bcd_in[15:12] == 4'hA) ? 0 : bcd_in[15:12];
                    bcd_out[11:8] <= (bcd_in[11:8] == 4'hA) ? 0 : bcd_in[11:8];
                    bcd_out[7:4] <= (bcd_in[7:4] == 4'hA) ? 0 : bcd_in[7:4];
                    bcd_out[3:0] <= (bcd_in[3:0] == 4'hA) ? 0 : bcd_in[3:0];
                    state <= INCREMENT;
                    busy <= 1;
                end else state <= IDLE;
            end
            INCREMENT: begin
                bcd_out <= bcd_out + 1;
                state <= CONVERT_BCD;
            end
            CONVERT_BCD: begin
                if (D_0 == 4'hA)
                    bcd_out <= bcd_out + 4'h6;
                else if (D_1 == 4'hA)
                    bcd_out <= bcd_out + 8'h60;
                else if (D_2 == 4'hA)
                    bcd_out <= bcd_out + 12'h600;
                else if (D_3 == 4'hA)
                    bcd_out <= bcd_out + 16'h6000;
                else if (D_4 == 4'hA)
                    bcd_out <= bcd_out + 20'h60000;
                else if (D_5 == 4'hA)
                    bcd_out <= bcd_out + 24'h600000;
                else if (D_6 == 4'hA)
                    bcd_out <= bcd_out + 28'h6000000;
                else state <= REMOVE_LEADING_ZEROES;
            end
            REMOVE_LEADING_ZEROES: begin
                if (bcd_out < 32'h10_000_000)
                    bcd_out <= {4'hA, bcd_out[27:0]};
                else if (bcd_out[31:28] == 4'hA && bcd_out[27:0] < 28'h1_000_000)
                    bcd_out <= {8'hAA, bcd_out[23:0]};
                else if (bcd_out[31:24] == 8'hAA && bcd_out[23:0] < 24'h100_000)
                    bcd_out <= {12'hAAA, bcd_out[19:0]};
                else if (bcd_out[31:20] == 12'hAAA && bcd_out[19:0] < 20'h10_000)
                    bcd_out <= {16'hAAAA, bcd_out[15:0]};
                else if (bcd_out[31:16] == 16'hAAAA && bcd_out[15:0] < 16'h1_000)
                    bcd_out <= {20'hAAAAA, bcd_out[11:0]};
                else if (bcd_out[31:12] == 20'hAAAAA && bcd_out[11:0] < 12'h100)
                    bcd_out <= {24'hAAAAAA, bcd_out[7:0]};
                else if (bcd_out[31:8] == 24'hAAAAAA && bcd_out[7:0] < 8'h10)
                    bcd_out <= {28'hAAAAAAA, bcd_out[3:0]};
                else begin
                    busy <= 0;
                    state <= DONE;
                end
            end
            DONE: begin
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase    
    end

endmodule
