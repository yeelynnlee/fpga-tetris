`timescale 1ns / 1ps

module blocks_pixel( input clk_in,
                    input [11:0] hcount_in, hcount1, hcount2, hcount4,
                    input [10:0] vcount_in,
                    input [2:0] next_block_color, hold_block_color,
                    output [11:0] next_block_pixel,
                    output [11:0] hold_block_pixel
    );

    logic [15:0] block_pixel_addr, next_pixel_addr, hold_pixel_addr;
    logic [1:0] block_pixel_color;
    
    assign block_pixel_addr = (next_pixel_addr) ? next_pixel_addr :
                              (hold_pixel_addr) ? hold_pixel_addr : 0;
    
    blocks block_map(.clka(clk_in), .addra(block_pixel_addr), .douta(block_pixel_color));
    
    block_display #(.BLOCK_X(1216), .BLOCK_Y(482))
       next_block(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), .hcount2(hcount2), 
       .hcount4(hcount4), .vcount_in(vcount_in), .block_color(next_block_color), 
       .block_pixel_color(block_pixel_color), .block_pixel_addr(next_pixel_addr),
       .block_pixel_out(next_block_pixel));
    
    block_display #(.BLOCK_X(1216), .BLOCK_Y(802))
       hold_block(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), .hcount2(hcount2), 
       .hcount4(hcount4), .vcount_in(vcount_in), .block_color(hold_block_color), 
       .block_pixel_color(block_pixel_color), .block_pixel_addr(hold_pixel_addr),
       .block_pixel_out(hold_block_pixel));

endmodule

module block_display #(parameter BLOCK_X,
                                 BLOCK_Y,
                                 BLOCK_WIDTH = 128,
                                 BLOCK_HEIGHT = 64)
                    ( input clk_in,
                      input [11:0] hcount_in, hcount1, hcount2, hcount4,
                      input [10:0] vcount_in,
                      input [2:0] block_color,
                      input [1:0] block_pixel_color,
                      output logic [15:0] block_pixel_addr,
                      output logic [11:0] block_pixel_out

    );
    
    localparam RED = 3'b001;
    localparam ORANGE = 3'b010;
    localparam YELLOW = 3'b011;
    localparam GREEN = 3'b100;
    localparam BLUE = 3'b101;
    localparam PURPLE = 3'b110;
    localparam CYAN = 3'b111;
    
    localparam RED_RGB = 12'hD00;
    localparam ORANGE_RGB = 12'hF63;
    localparam YELLOW_RGB = 12'hFB3;
    localparam GREEN_RGB = 12'h273;
    localparam BLUE_RGB = 12'h17D;
    localparam PURPLE_RGB = 12'h969;
    localparam CYAN_RGB = 12'h267;
    localparam WHITE_RGB = 12'hFFF;
    
    localparam BLACK = 0;
    localparam COLOR = 1;
    localparam WHITE = 2;
    
    logic [6:0] part_row;
    logic [5:0] num_full_rows;
    logic [15:0] full_rows;
    
    logic [11:0] block_rgb;
    always_comb begin
        case(block_color)
            RED: block_rgb = RED_RGB;
            ORANGE: block_rgb = ORANGE_RGB;
            YELLOW: block_rgb = YELLOW_RGB;
            GREEN: block_rgb = GREEN_RGB;
            BLUE: block_rgb = BLUE_RGB;
            PURPLE: block_rgb = PURPLE_RGB;
            CYAN: block_rgb = CYAN_RGB;
            default: block_rgb = 0;
        endcase
    end
    
    always_ff @ (posedge clk_in) begin
        num_full_rows <= vcount_in - BLOCK_Y;
        
        part_row <= hcount1 - BLOCK_X;
        full_rows <= num_full_rows * BLOCK_WIDTH;
         
        if (hcount2 >= BLOCK_X && hcount2 < BLOCK_X + BLOCK_WIDTH
          && vcount_in >= BLOCK_Y && vcount_in < BLOCK_Y + BLOCK_HEIGHT) begin
            case(block_color)
                RED: block_pixel_addr <= part_row + full_rows + 0 * BLOCK_WIDTH * BLOCK_HEIGHT;
                ORANGE: block_pixel_addr <= part_row + full_rows + 1 * BLOCK_WIDTH * BLOCK_HEIGHT;
                YELLOW: block_pixel_addr <= part_row + full_rows + 2 * BLOCK_WIDTH * BLOCK_HEIGHT;
                GREEN: block_pixel_addr <= part_row + full_rows + 3 * BLOCK_WIDTH * BLOCK_HEIGHT;
                BLUE: block_pixel_addr <= part_row + full_rows + 4 * BLOCK_WIDTH * BLOCK_HEIGHT;
                PURPLE: block_pixel_addr <= part_row + full_rows + 5 * BLOCK_WIDTH * BLOCK_HEIGHT;
                CYAN: block_pixel_addr <= part_row + full_rows + 6 * BLOCK_WIDTH * BLOCK_HEIGHT;
                default: block_pixel_addr <= 0;
            endcase
        end else block_pixel_addr <= 0;
        
        if (hcount4 >= BLOCK_X && hcount4 < BLOCK_X + BLOCK_WIDTH
          && vcount_in >= BLOCK_Y && vcount_in < BLOCK_Y + BLOCK_HEIGHT) begin
            case(block_pixel_color)
                BLACK: block_pixel_out <= 0;
                COLOR: block_pixel_out <= block_rgb;
                WHITE: block_pixel_out <= WHITE_RGB;
            endcase
        end else block_pixel_out <= 0;
    end
    
endmodule