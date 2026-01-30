`timescale 1ns / 1ps

module num_pixel(   input clk_in,
                    input [11:0] hcount_in, hcount2, hcount4,
                    input [10:0] vcount_in,
                    input [31:0] score_bcd, level_bcd, lines_bcd,
                    output [11:0] score_num_pixel,
                    output [11:0] level_num_pixel,
                    output [11:0] lines_num_pixel
                    
    );
    
    logic [13:0] num_pixel_addr, score_pixel_addr, level_pixel_addr, lines_pixel_addr;
    logic num_pixel_color;
    
    assign num_pixel_addr = (score_pixel_addr) ? score_pixel_addr :
                            (level_pixel_addr) ? level_pixel_addr :
                            (lines_pixel_addr) ? lines_pixel_addr : 0;
                            
    numbers num_map(.clka(clk_in), .addra(num_pixel_addr), .douta(num_pixel_color));
    
    num_display #(.DISP_X(464), .DISP_Y(514))
       score_num(.clk_in(clk_in), .hcount_in(hcount_in), .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .bcd_in(score_bcd), .num_pixel_color(num_pixel_color), .num_pixel_addr(score_pixel_addr), .num_pixel_out(score_num_pixel));
    
    num_display #(.DISP_X(464), .DISP_Y(658))
       level_num(.clk_in(clk_in), .hcount_in(hcount_in), .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .bcd_in(level_bcd), .num_pixel_color(num_pixel_color), .num_pixel_addr(level_pixel_addr), .num_pixel_out(level_num_pixel));
    
    num_display #(.DISP_X(464), .DISP_Y(802))
       lines_num(.clk_in(clk_in), .hcount_in(hcount_in), .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .bcd_in(lines_bcd), .num_pixel_color(num_pixel_color), .num_pixel_addr(lines_pixel_addr), .num_pixel_out(lines_num_pixel));

endmodule

module num_display #(parameter DISP_X, 
                               DISP_Y,
                               DISP_WIDTH = 256,
                               DISP_HEIGHT = 32,
                               DIGIT_WIDTH = 32,
                               DIGIT_HEIGHT = 32,
                               NUM_COLOR = 12'hFFF)
                    (input clk_in,
                     input [11:0] hcount_in, hcount2, hcount4,
                     input [10:0] vcount_in,
                     input [31:0] bcd_in,
                     input num_pixel_color,
                     output logic [13:0] num_pixel_addr,
                     output logic [11:0] num_pixel_out      

    );
    
    logic [7:0] num_x;
    logic [5:0] num_y;
    logic [4:0] part_row;
    logic [13:0] full_rows;
    logic [2:0] digit_index;
    logic [3:0] digit_value;
    
    always_comb begin
        case(digit_index)
            0: digit_value = bcd_in[3:0];
            1: digit_value = bcd_in[7:4];
            2: digit_value = bcd_in[11:8];
            3: digit_value = bcd_in[15:12];
            4: digit_value = bcd_in[19:16];
            5: digit_value = bcd_in[23:20];
            6: digit_value = bcd_in[27:24];
            7: digit_value = bcd_in[31:28];
        endcase
    end
    
    always_ff @ (posedge clk_in) begin
        num_x <= hcount_in - DISP_X;
        num_y <= vcount_in - DISP_Y;
        
        part_row <= num_x[4:0];
        full_rows <= num_y * DIGIT_WIDTH;
        digit_index <= 7 - (num_x >> 5);
        
        if (hcount2 >= DISP_X && hcount2 < DISP_X + DISP_WIDTH &&
          vcount_in >= DISP_Y && vcount_in < DISP_Y + DISP_HEIGHT) begin
            case(digit_value)
                0: num_pixel_addr <= part_row + full_rows + 0 * DIGIT_WIDTH * DIGIT_HEIGHT;
                1: num_pixel_addr <= part_row + full_rows + 1 * DIGIT_WIDTH * DIGIT_HEIGHT;
                2: num_pixel_addr <= part_row + full_rows + 2 * DIGIT_WIDTH * DIGIT_HEIGHT;
                3: num_pixel_addr <= part_row + full_rows + 3 * DIGIT_WIDTH * DIGIT_HEIGHT;
                4: num_pixel_addr <= part_row + full_rows + 4 * DIGIT_WIDTH * DIGIT_HEIGHT;
                5: num_pixel_addr <= part_row + full_rows + 5 * DIGIT_WIDTH * DIGIT_HEIGHT;
                6: num_pixel_addr <= part_row + full_rows + 6 * DIGIT_WIDTH * DIGIT_HEIGHT;
                7: num_pixel_addr <= part_row + full_rows + 7 * DIGIT_WIDTH * DIGIT_HEIGHT;
                8: num_pixel_addr <= part_row + full_rows + 8 * DIGIT_WIDTH * DIGIT_HEIGHT;
                9: num_pixel_addr <= part_row + full_rows + 9 * DIGIT_WIDTH * DIGIT_HEIGHT;
                4'hA: num_pixel_addr <= 0;
                default: num_pixel_addr <= 0;
            endcase
        end else num_pixel_addr <= 0;
        
        if (hcount4 >= DISP_X && hcount4 < DISP_X + DISP_WIDTH &&
          vcount_in >= DISP_Y && vcount_in < DISP_Y + DISP_HEIGHT) begin
            case(num_pixel_color)
                0: num_pixel_out <= 0;
                1: num_pixel_out <= NUM_COLOR;
            endcase
        end else num_pixel_out <= 0;
    end
    
endmodule