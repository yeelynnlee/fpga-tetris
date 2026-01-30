`timescale 1ns / 1ps

module display(         input clk_in,
                        input [11:0] hcount_in,
                        input [10:0] vcount_in,
                        input hsync_in,
                        input vsync_in,
                        input blank_in,
                        input [5:0] game_state,
                        input start_blink,
                        input pause_select,
                        input game_over_select,
                        input write_enable,
                        input [8:0] square_write_addr,
                        input [3:0] write_color,
                        input flash_enable,
                        input [8:0] flash_write_addr,
                        input flash_write,
                        input speck_enable,
                        input [8:0] speck_write_addr,
                        input speck_write,
                        input [2:0] next_block_color,
                        input [2:0] hold_block_color,
                        input [31:0] score_bcd,
                        input [31:0] level_bcd,
                        input [31:0] lines_bcd,
                        output logic thsync_out,
                        output logic tvsync_out,
                        output logic tblank_out,
                        output logic [11:0] pixel_out

    );
     
    logic [11:0] hcount1, hcount2, hcount3, hcount4;
    logic hsync1, hsync2, hsync3, hsync4, vsync1, vsync2, vsync3, vsync4, blank1, blank2, blank3, blank4;
    always_ff @ (posedge clk_in) begin
        {hcount4, hcount3, hcount2, hcount1} <= {hcount3, hcount2, hcount1, hcount_in};
        {thsync_out, hsync4, hsync3, hsync2, hsync1} <= {hsync4, hsync3, hsync2, hsync1, hsync_in};
        {tvsync_out, vsync4, vsync3, vsync2, vsync1} <= {vsync4, vsync3, vsync2, vsync1, vsync_in};
        {tblank_out, blank4, blank3, blank2, blank1} <= {blank4, blank3, blank2, blank1, blank_in};
    end
       
    logic [11:0] cathedral_pixel;
    cathedral_display #(.CATHEDRAL_X(1024), .CATHEDRAL_Y(474))
       cathedral(.clk_in(clk_in), .hcount_in(hcount_in), .hcount4(hcount4), .vcount_in(vcount_in),
       .cathedral_pixel_out(cathedral_pixel));
    
    logic [11:0] grid_pixel;
    grid_display grid(.clk_in(clk_in), .hcount_in(hcount_in), .hcount4(hcount4), .vcount_in(vcount_in),
       .write_enable(write_enable), .square_write_addr(square_write_addr), .write_color(write_color),
       .grid_pixel_out(grid_pixel));
       
    logic [11:0] speck_pixel;
    speck_display speck(.clk_in(clk_in), .hcount_in(hcount_in), .hcount4(hcount4), .vcount_in(vcount_in),
       .speck_enable(speck_enable), .speck_write_addr(speck_write_addr), .speck_write(speck_write), 
       .speck_pixel_out(speck_pixel));
    
    logic [11:0] flash_pixel;
    flash_display flash(.clk_in(clk_in), .hcount_in(hcount_in), .hcount4(hcount4), .vcount_in(vcount_in),
       .flash_enable(flash_enable), .flash_write_addr(flash_write_addr), .flash_write(flash_write),
       .flash_pixel_out(flash_pixel));
    
    logic [11:0] start_box_pixel, start_blink_box_pixel, grid_outline_pixel, score_box_pixel,
       score_divider_pixel, next_outer_box_pixel, next_inner_box_pixel, hold_outer_box_pixel,
       hold_inner_box_pixel, popup_box_pixel, popup_solid_box_pixel, option1_box_pixel,
       option1_select_box_pixel, option2_box_pixel, option2_select_box_pixel;
    box_pixel boxes(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in),
       .start_box_pixel(start_box_pixel), .start_blink_box_pixel(start_blink_box_pixel),
       .grid_outline_pixel(grid_outline_pixel), .score_box_pixel(score_box_pixel),
       .score_divider_pixel(score_divider_pixel), .next_outer_box_pixel(next_outer_box_pixel),
       .next_inner_box_pixel(next_inner_box_pixel), .hold_outer_box_pixel(hold_outer_box_pixel),
       .hold_inner_box_pixel(hold_inner_box_pixel), .popup_box_pixel(popup_box_pixel),
       .popup_solid_box_pixel(popup_solid_box_pixel), .option1_box_pixel(option1_box_pixel),
       .option1_select_box_pixel(option1_select_box_pixel), .option2_box_pixel(option2_box_pixel),
       .option2_select_box_pixel(option2_select_box_pixel));
    
    logic [11:0] start_title_pixel, title_pixel, start_heading_pixel, paused_heading_pixel, 
       game_over_heading_pixel, score_text_pixel, level_text_pixel, lines_text_pixel, next_text_pixel, 
       hold_text_pixel, resume_text_pixel, quit_text_pixel, play_text_pixel, again_text_pixel;
    text_pixel text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1),  
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in), 
       .start_title_pixel(start_title_pixel), .title_pixel(title_pixel),
       .start_heading_pixel(start_heading_pixel), .paused_heading_pixel(paused_heading_pixel),
       .game_over_heading_pixel(game_over_heading_pixel), .score_text_pixel(score_text_pixel), 
       .level_text_pixel(level_text_pixel), .lines_text_pixel(lines_text_pixel), .next_text_pixel(next_text_pixel), 
       .hold_text_pixel(hold_text_pixel), .resume_text_pixel(resume_text_pixel), .quit_text_pixel(quit_text_pixel), 
       .play_text_pixel(play_text_pixel), .again_text_pixel(again_text_pixel));    
    
    logic [11:0] score_num_pixel, level_num_pixel, lines_num_pixel;
    num_pixel numbers(.clk_in(clk_in), .hcount_in(hcount_in), .hcount2(hcount2), .hcount4(hcount4),
       .vcount_in(vcount_in), .score_bcd(score_bcd), .level_bcd(level_bcd), .lines_bcd(lines_bcd),
       .score_num_pixel(score_num_pixel), .level_num_pixel(level_num_pixel), .lines_num_pixel(lines_num_pixel));
    
    logic [11:0] next_block_pixel, hold_block_pixel;
    blocks_pixel blocks(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), .hcount2(hcount2),
       .hcount4(hcount4), .vcount_in(vcount_in), .next_block_color(next_block_color), 
       .hold_block_color(hold_block_color), .next_block_pixel(next_block_pixel), .hold_block_pixel(hold_block_pixel)); 

    parameter START_SCREEN = 0;
    parameter GAME_PAUSE = 33;
    parameter GAME_OVER = 34;
    
    logic [11:0] game_pause_pixel;  
    logic [11:0] game_over_pixel;
    
    always_comb begin
        if (game_state == GAME_PAUSE) begin
            game_pause_pixel = (popup_box_pixel) ? popup_box_pixel :
                               (paused_heading_pixel) ? paused_heading_pixel :
                               ((~pause_select) && (option1_select_box_pixel)) ? option1_select_box_pixel :
                               (option1_box_pixel) ? option1_box_pixel : 
                               (resume_text_pixel) ? resume_text_pixel :
                               ((pause_select) && (option2_select_box_pixel)) ? option2_select_box_pixel :
                               (option2_box_pixel) ? option2_box_pixel : 
                               (quit_text_pixel) ? quit_text_pixel :
                               (popup_solid_box_pixel) ? popup_solid_box_pixel : 0;
        end else game_pause_pixel = 0;
        if (game_state == GAME_OVER) begin
            game_over_pixel = (popup_box_pixel) ? popup_box_pixel :
                               (game_over_heading_pixel) ? game_over_heading_pixel :
                               ((~game_over_select) && (option1_select_box_pixel)) ? option1_select_box_pixel :
                               (option1_box_pixel) ? option1_box_pixel : 
                               (play_text_pixel) ? play_text_pixel :
                               (again_text_pixel) ? again_text_pixel :
                               ((game_over_select) && (option2_select_box_pixel)) ? option2_select_box_pixel :
                               (option2_box_pixel) ? option2_box_pixel : 
                               (quit_text_pixel) ? quit_text_pixel :
                               (popup_solid_box_pixel) ? popup_solid_box_pixel : 0;
        end else game_over_pixel = 0;
        if (game_state == START_SCREEN) begin
            pixel_out = (start_title_pixel) ? start_title_pixel :
                        ((start_blink) && (start_blink_box_pixel)) ? start_blink_box_pixel :
                        (start_box_pixel) ? start_box_pixel :
                        (start_heading_pixel) ? start_heading_pixel : 
                        (cathedral_pixel) ? cathedral_pixel : 0;
        end else begin
            pixel_out = (game_pause_pixel) ? game_pause_pixel :
                        (game_over_pixel) ? game_over_pixel :
                        (flash_pixel) ? flash_pixel :
                        (grid_pixel) ? grid_pixel : 
                        (speck_pixel) ? speck_pixel :
                        (grid_outline_pixel) ? grid_outline_pixel :
                        (score_box_pixel) ? score_box_pixel :
                        (score_divider_pixel) ? score_divider_pixel :
                        (next_outer_box_pixel) ? next_outer_box_pixel :
                        (next_inner_box_pixel) ? next_inner_box_pixel :
                        (hold_outer_box_pixel) ? hold_outer_box_pixel :
                        (hold_inner_box_pixel) ? hold_inner_box_pixel :
                        (title_pixel) ? title_pixel :
                        (score_text_pixel) ? score_text_pixel : 
                        (level_text_pixel) ? level_text_pixel : 
                        (lines_text_pixel) ? lines_text_pixel : 
                        (next_text_pixel) ? next_text_pixel : 
                        (hold_text_pixel) ? hold_text_pixel : 
                        (next_block_pixel) ? next_block_pixel : 
                        (hold_block_pixel) ? hold_block_pixel :
                        (score_num_pixel) ? score_num_pixel : 
                        (level_num_pixel) ? level_num_pixel : 
                        (lines_num_pixel) ? lines_num_pixel : 0; 
        end
    end   
    
endmodule