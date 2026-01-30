`timescale 1ns / 1ps

module flash_display(   input clk_in,
                        input [11:0] hcount_in, hcount4,
                        input [10:0] vcount_in,
                        input flash_enable,
                        input [8:0] flash_write_addr,
                        input flash_write,
                        output logic [11:0] flash_pixel_out
                        
    );
    
    parameter GRID_START_X = 800;
    parameter GRID_START_Y = 330;
    parameter SIDE_LENGTH = 32;
    
    parameter ROW_WIDTH = 10;
    parameter NUM_ROWS = 20;
    parameter ROW_START_X = 3;
    parameter ROW_START_Y = 1;
    parameter MAP_WIDTH = 14;
    
    parameter WHITE_RGB = 12'hFFF;
    
    logic [8:0] grid_x;
    logic [9:0] grid_y;
    logic [3:0] square_part_row;
    logic [8:0] square_full_rows;
    logic [8:0] square_addr;
    logic flash_on;
    logic [4:0] flash_part_row;
    logic [9:0] flash_full_rows;
    logic [9:0] flash_pixel_addr;
    logic [1:0] flash_pixel_color;
    
    always_ff @ (posedge clk_in) begin
        grid_x <= hcount_in - GRID_START_X;
        grid_y <= vcount_in - GRID_START_Y;
        
        square_part_row <= (grid_x >> 5) + ROW_START_X;
        square_full_rows <= ((grid_y >> 5) + ROW_START_Y) * MAP_WIDTH;
        flash_part_row <= grid_x[4:0];
        flash_full_rows <= grid_y[4:0] * SIDE_LENGTH;
        
        square_addr <= square_part_row + square_full_rows;
        flash_pixel_addr <= flash_part_row + flash_full_rows;
    end
    
    flash_map flash_display_map(.clka(clk_in), .wea(flash_enable), .addra(flash_write_addr),
       .dina(flash_write), .clkb(clk_in), .addrb(square_addr), .doutb(flash_on));
    
    block_pixel block_pixel_map(.clka(clk_in), .addra(flash_pixel_addr), .douta(flash_pixel_color));
    
    always_ff @ (posedge clk_in) begin
        if (hcount4 >= GRID_START_X && hcount4 < GRID_START_X + ROW_WIDTH * SIDE_LENGTH
          && vcount_in >= GRID_START_Y && vcount_in < GRID_START_Y + NUM_ROWS * SIDE_LENGTH)
            flash_pixel_out <= ((flash_on) && (flash_pixel_color)) ? WHITE_RGB : 0;
        else flash_pixel_out <= 0;
    end
       
endmodule
