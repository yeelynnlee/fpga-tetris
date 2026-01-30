`timescale 1ns / 1ps

module cathedral_display #(parameter CATHEDRAL_X,
                                     CATHEDRAL_Y)
                          (   input clk_in,
                              input [11:0] hcount_in, hcount4,
                              input [10:0] vcount_in,
                              output logic [11:0] cathedral_pixel_out

    );
    
    localparam CATHEDRAL_WIDTH = 512;
    localparam CATHEDRAL_HEIGHT = 496;
    
    localparam PIXEL_MAP_WIDTH = 64;
    
    localparam RED = 4'b0001;
    localparam ORANGE = 4'b0010;
    localparam YELLOW = 4'b0011;
    localparam GREEN = 4'b0100;
    localparam BLUE = 4'b0101;
    localparam PURPLE = 4'b0110;
    localparam CYAN = 4'b0111;
    localparam WHITE = 4'b1000;
    
    localparam RED_RGB = 12'hD00;
    localparam ORANGE_RGB = 12'hF63;
    localparam YELLOW_RGB = 12'hFB3;
    localparam GREEN_RGB = 12'h273;
    localparam BLUE_RGB = 12'h17D;
    localparam PURPLE_RGB = 12'h969;
    localparam CYAN_RGB = 12'h267;
    localparam WHITE_RGB = 12'hFFF;
    
    logic [8:0] x_coord;
    logic [9:0] y_coord;  
    logic [5:0] part_row;
    logic [11:0] full_rows;  
    logic [11:0] cathedral_pixel_addr;
    logic [3:0] cathedral_pixel_color;
    
    always_ff @ (posedge clk_in) begin
        x_coord <= hcount_in - CATHEDRAL_X;
        y_coord <= vcount_in - CATHEDRAL_Y;
        part_row <= x_coord >> 3;
        full_rows <= (y_coord >> 3) * PIXEL_MAP_WIDTH;
        cathedral_pixel_addr <= part_row + full_rows;
    end
    
    cathedral cathedral_pixel_map(.clka(clk_in), .addra(cathedral_pixel_addr), .douta(cathedral_pixel_color));
    
    always_ff @ (posedge clk_in) begin
        if (hcount4 >= CATHEDRAL_X && hcount4 < CATHEDRAL_X + CATHEDRAL_WIDTH
          && vcount_in >= CATHEDRAL_Y && vcount_in < CATHEDRAL_Y + CATHEDRAL_HEIGHT) begin
            case(cathedral_pixel_color)
                RED: cathedral_pixel_out <= RED_RGB;
                ORANGE: cathedral_pixel_out <= ORANGE_RGB;
                YELLOW: cathedral_pixel_out <= YELLOW_RGB;
                GREEN: cathedral_pixel_out <= GREEN_RGB;
                BLUE: cathedral_pixel_out <= BLUE_RGB;
                PURPLE: cathedral_pixel_out <= PURPLE_RGB;
                CYAN: cathedral_pixel_out <= CYAN_RGB;
                WHITE: cathedral_pixel_out <= WHITE_RGB;
                default: cathedral_pixel_out <= 0;
            endcase
        end else cathedral_pixel_out <= 0;
    end
    
endmodule