`timescale 1ns / 1ps

module scoring( input clk_in,
                input [5:0] game_state,
                input start,
                input [2:0] rows_cleared,
                input [4:0] level,
                input [4:0] soft_drop_points,
                input [4:0] block_y,
                input [4:0] ghost_y,
                output logic [23:0] score

    );
    
    parameter RESET = 1;
    
    parameter IDLE = 0;
    parameter CALC_POINTS = 1;
    parameter ADD_SCORE = 2;

    parameter SINGLE = 1;
    parameter DOUBLE = 2;
    parameter TRIPLE = 3;
    parameter TETRIS = 4;
    
    logic [1:0] state;
    
    logic [10:0] clear_multiplier;
    logic [9:0] combo_multiplier;
    
    logic [15:0] clear_points;
    logic [13:0] combo_points;
    logic [5:0] hard_drop_points;
    
    logic [2:0] last_clear;
    logic [3:0] combo_count;
    
    always_ff @ (posedge clk_in) begin
        if (game_state == RESET) begin
            last_clear <= 0;
            combo_count <= 0;
            score <= 0;
            state <= IDLE;
        end else case(state)
            IDLE: begin
                if (start) begin
                    case(rows_cleared)
                        SINGLE: clear_multiplier <= 100;
                        DOUBLE: clear_multiplier <= 300;
                        TRIPLE: clear_multiplier <= 500;
                        TETRIS: clear_multiplier <= (last_clear == TETRIS) ? 1600 : 800;
                        default: clear_multiplier <= 0;
                    endcase
                    combo_multiplier <= (rows_cleared) ? 50 * combo_count : 0;
                    state <= CALC_POINTS;
                end else state <= IDLE;
            end
            CALC_POINTS: begin
                clear_points <= clear_multiplier * level;
                combo_points <= combo_multiplier * level;
                hard_drop_points <= 2 * (ghost_y - block_y);
                last_clear <= (rows_cleared > 0) ? rows_cleared : last_clear;
                combo_count <= (rows_cleared > 0) ? combo_count + 1 : 0;
                state <= ADD_SCORE;
            end
            ADD_SCORE: begin
                score <= score + clear_points + combo_points + soft_drop_points + hard_drop_points;
                state <= IDLE;
            end
        endcase
    end
    
endmodule