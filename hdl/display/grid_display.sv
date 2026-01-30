`timescale 1ns / 1ps

module grid_display(    input clk_in,
                        input [11:0] hcount_in, hcount4,
                        input [10:0] vcount_in,
                        input write_enable,
                        input [8:0] square_write_addr,
                        input [3:0] write_color,
                        output logic [11:0] grid_pixel_out

    );
    
    parameter GRID_START_X = 800;
    parameter GRID_START_Y = 330;
    parameter SIDE_LENGTH = 32;
    
    parameter ROW_WIDTH = 10;
    parameter NUM_ROWS = 20;
    parameter ROW_START_X = 3;
    parameter ROW_START_Y = 1;
    parameter MAP_WIDTH = 14;
    
    parameter RED = 3'b001;
    parameter ORANGE = 3'b010;
    parameter YELLOW = 3'b011;
    parameter GREEN = 3'b100;
    parameter BLUE = 3'b101;
    parameter PURPLE = 3'b110;
    parameter CYAN = 3'b111;
    
    parameter RED_RGB = 12'hD00;
    parameter ORANGE_RGB = 12'hF63;
    parameter YELLOW_RGB = 12'hFB3;
    parameter GREEN_RGB = 12'h273;
    parameter BLUE_RGB = 12'h17D;
    parameter PURPLE_RGB = 12'h969;
    parameter CYAN_RGB = 12'h267;
    parameter WHITE_RGB = 12'hFFF;
    
    parameter BLACK = 0;
    parameter COLOR = 1;
    parameter WHITE = 2;
    
    logic [8:0] grid_x;
    logic [9:0] grid_y;
    logic [3:0] square_part_row;
    logic [8:0] square_full_rows;    
    logic [8:0] square_addr;
    logic [3:0] square_color;
    
    always_ff @ (posedge clk_in) begin
        grid_x <= hcount_in - GRID_START_X;
        grid_y <= vcount_in - GRID_START_Y;
        
        square_part_row <= (grid_x >> 5) + ROW_START_X;
        square_full_rows <= ((grid_y >> 5) + ROW_START_Y) * MAP_WIDTH;
        square_addr <= square_part_row + square_full_rows;
    end
    
    square_map grid_display_map(.clka(clk_in), .wea(write_enable), .addra(square_write_addr), .dina(write_color),
       .clkb(clk_in), .addrb(square_addr), .doutb(square_color));
    
    logic [11:0] square_color_rgb;
    always_comb begin
        case(square_color[2:0])
            RED: square_color_rgb = RED_RGB;
            ORANGE: square_color_rgb = ORANGE_RGB;
            YELLOW: square_color_rgb = YELLOW_RGB;
            GREEN: square_color_rgb = GREEN_RGB;
            BLUE: square_color_rgb = BLUE_RGB;
            PURPLE: square_color_rgb = PURPLE_RGB;
            CYAN: square_color_rgb = CYAN_RGB;
            default: square_color_rgb = 0;
        endcase
    end
    
    logic [4:0] grid_part_row;
    logic [9:0] grid_full_rows;
    logic [9:0] grid_pixel_addr;
    logic [1:0] grid_pixel_color;
    
    always_ff @ (posedge clk_in) begin
        grid_part_row <= grid_x[4:0];
        grid_full_rows <= grid_y[4:0] * SIDE_LENGTH;
        grid_pixel_addr <= grid_part_row + grid_full_rows;
    end
    
    logic [1:0] block_pixel_color;
    logic ghost_pixel_color;
    block_pixel block_pixel_map(.clka(clk_in), .addra(grid_pixel_addr), .douta(block_pixel_color));
    ghost_pixel ghost_pixel_map(.clka(clk_in), .addra(grid_pixel_addr), .douta(ghost_pixel_color));
    
    assign grid_pixel_color = (!square_color) ? BLACK : (!square_color[3]) ? block_pixel_color : ghost_pixel_color;
    
    always_ff @ (posedge clk_in) begin
        if (hcount4 >= GRID_START_X && hcount4 < GRID_START_X + ROW_WIDTH * SIDE_LENGTH
          && vcount_in >= GRID_START_Y && vcount_in < GRID_START_Y + NUM_ROWS * SIDE_LENGTH) begin
            case(grid_pixel_color)
                BLACK: grid_pixel_out <= 0;
                COLOR: grid_pixel_out <= square_color_rgb;
                WHITE: grid_pixel_out <= WHITE_RGB;
            endcase
        end else grid_pixel_out <= 0;
    end
    
endmodule
