`timescale 1ns / 1ps

module text_pixel(  input clk_in,
                    input [11:0] hcount_in, hcount1, hcount2, hcount4,
                    input [10:0] vcount_in,
                    output [11:0] start_title_pixel,
                    output [11:0] title_pixel,
                    output [11:0] start_heading_pixel,
                    output [11:0] paused_heading_pixel,
                    output [11:0] game_over_heading_pixel,
                    output [11:0] score_text_pixel,
                    output [11:0] level_text_pixel,
                    output [11:0] lines_text_pixel,
                    output [11:0] next_text_pixel,
                    output [11:0] hold_text_pixel,
                    output [11:0] resume_text_pixel,
                    output [11:0] quit_text_pixel,
                    output [11:0] play_text_pixel,
                    output [11:0] again_text_pixel
                              
    );
    
    logic [15:0] start_title_pixel_addr, title_pixel_addr;
    logic start_title_pixel_color, title_pixel_color;
    
    title title_map(.clka(clk_in), .addra(start_title_pixel_addr), .douta(start_title_pixel_color), 
       .clkb(clk_in), .addrb(title_pixel_addr), .doutb(title_pixel_color));
    
    text_display #(.TEXT_X(520), .TEXT_Y(110), .TEXT_WIDTH(440), .TEXT_HEIGHT(110), 
    .ADDR_WIDTH(16), .SCALE_POWER(1))
       start_title(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(start_title_pixel_color), .text_pixel_addr(start_title_pixel_addr), .text_pixel_out(start_title_pixel));
    
    text_display #(.TEXT_X(740), .TEXT_Y(110), .TEXT_WIDTH(440), .TEXT_HEIGHT(110), 
    .ADDR_WIDTH(16))
       title(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(title_pixel_color), .text_pixel_addr(title_pixel_addr), .text_pixel_out(title_pixel));
    
    logic [15:0] heading_pixel_addra, heading_pixel_addrb, start_pixel_addr, paused_pixel_addr, game_over_pixel_addr;
    logic heading_pixel_colora, heading_pixel_colorb;
    
    assign heading_pixel_addra = (paused_pixel_addr) ? paused_pixel_addr :
                                 (start_pixel_addr) ? start_pixel_addr : 0;
    assign heading_pixel_addrb = game_over_pixel_addr;
    
    heading heading_map(.clka(clk_in), .addra(heading_pixel_addra), .douta(heading_pixel_colora),
       .clkb(clk_in), .addrb(heading_pixel_addrb), .doutb(heading_pixel_colorb));
    
    text_display #(.TEXT_X(426), .TEXT_Y(661), .TEXT_WIDTH(332), .TEXT_HEIGHT(44), 
    .ADDR_WIDTH(16), .SCALE_POWER(1), .WORD_INDEX(0))
       start_heading(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(heading_pixel_colora), .text_pixel_addr(start_pixel_addr), .text_pixel_out(start_heading_pixel));
       
    text_display #(.TEXT_X(852), .TEXT_Y(539), .TEXT_WIDTH(332), .TEXT_HEIGHT(44), 
    .ADDR_WIDTH(16), .WORD_INDEX(1))
       paused_heading(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(heading_pixel_colora), .text_pixel_addr(paused_pixel_addr), .text_pixel_out(paused_heading_pixel));
    
    text_display #(.TEXT_X(794), .TEXT_Y(539), .TEXT_WIDTH(332), .TEXT_HEIGHT(44), 
    .ADDR_WIDTH(16), .WORD_INDEX(2))
       game_over_heading(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(heading_pixel_colorb), .text_pixel_addr(game_over_pixel_addr), .text_pixel_out(game_over_heading_pixel));    
    
    logic [14:0] text_pixel_addr, score_pixel_addr, level_pixel_addr, lines_pixel_addr, 
      next_pixel_addr, hold_pixel_addr;
    logic text_pixel_color;
    
    assign text_pixel_addr = (score_pixel_addr) ? score_pixel_addr :
                             (level_pixel_addr) ? level_pixel_addr :
                             (lines_pixel_addr) ? lines_pixel_addr :
                             (next_pixel_addr) ? next_pixel_addr :
                             (hold_pixel_addr) ? hold_pixel_addr : 0;
    
    text text_map(.clka(clk_in), .addra(text_pixel_addr), .douta(text_pixel_color));
    
    text_display #(.TEXT_X(464), .TEXT_Y(450), .TEXT_WIDTH(126), .TEXT_HEIGHT(33), 
    .ADDR_WIDTH(15), .WORD_INDEX(0))
       score_text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(text_pixel_color), .text_pixel_addr(score_pixel_addr), .text_pixel_out(score_text_pixel));
       
    text_display #(.TEXT_X(464), .TEXT_Y(594), .TEXT_WIDTH(126), .TEXT_HEIGHT(33), 
    .ADDR_WIDTH(15), .WORD_INDEX(1))
       level_text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(text_pixel_color), .text_pixel_addr(level_pixel_addr), .text_pixel_out(level_text_pixel));
    
    text_display #(.TEXT_X(464), .TEXT_Y(738), .TEXT_WIDTH(126), .TEXT_HEIGHT(33), 
    .ADDR_WIDTH(15), .WORD_INDEX(2))
       lines_text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(text_pixel_color), .text_pixel_addr(lines_pixel_addr), .text_pixel_out(lines_text_pixel));
    
    text_display #(.TEXT_X(1230), .TEXT_Y(418), .TEXT_WIDTH(126), .TEXT_HEIGHT(33), 
    .ADDR_WIDTH(15), .WORD_INDEX(3))
       next_text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(text_pixel_color), .text_pixel_addr(next_pixel_addr), .text_pixel_out(next_text_pixel));
    
    text_display #(.TEXT_X(1233), .TEXT_Y(738), .TEXT_WIDTH(126), .TEXT_HEIGHT(33), 
    .ADDR_WIDTH(15), .WORD_INDEX(4))
       hold_text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(text_pixel_color), .text_pixel_addr(hold_pixel_addr), .text_pixel_out(hold_text_pixel));
    
    logic [14:0] button_text_pixel_addra, button_text_pixel_addrb, 
       resume_pixel_addr, quit_pixel_addr, play_pixel_addr, again_pixel_addr;
    logic button_text_pixel_colora, button_text_pixel_colorb;
    
    assign button_text_pixel_addra = (resume_pixel_addr) ? resume_pixel_addr :
                                     (quit_pixel_addr) ? quit_pixel_addr : 0;
    assign button_text_pixel_addrb = (again_pixel_addr) ? again_pixel_addr :
                                     (play_pixel_addr) ? play_pixel_addr : 0;                          
    
    button_text button_text_map(.clka(clk_in), .addra(button_text_pixel_addra), .douta(button_text_pixel_colora), 
    .clkb(clk_in), .addrb(button_text_pixel_addrb), .doutb(button_text_pixel_colorb));
    
    text_display #(.TEXT_X(884), .TEXT_Y(627), .TEXT_WIDTH(153), .TEXT_HEIGHT(48), 
    .ADDR_WIDTH(15), .WORD_INDEX(0))
       resume_text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(button_text_pixel_colora), .text_pixel_addr(resume_pixel_addr), .text_pixel_out(resume_text_pixel));
    
    text_display #(.TEXT_X(914), .TEXT_Y(712), .TEXT_WIDTH(153), .TEXT_HEIGHT(48), 
    .ADDR_WIDTH(15), .WORD_INDEX(1))
       quit_text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(button_text_pixel_colora), .text_pixel_addr(quit_pixel_addr), .text_pixel_out(quit_text_pixel));
    
    text_display #(.TEXT_X(841), .TEXT_Y(627), .TEXT_WIDTH(153), .TEXT_HEIGHT(48), 
    .ADDR_WIDTH(15), .WORD_INDEX(2))
       play_text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(button_text_pixel_colorb), .text_pixel_addr(play_pixel_addr), .text_pixel_out(play_text_pixel));
       
    text_display #(.TEXT_X(953), .TEXT_Y(627), .TEXT_WIDTH(153), .TEXT_HEIGHT(48), 
    .ADDR_WIDTH(15), .WORD_INDEX(3))
       again_text(.clk_in(clk_in), .hcount_in(hcount_in), .hcount1(hcount1), 
       .hcount2(hcount2), .hcount4(hcount4), .vcount_in(vcount_in),
       .text_pixel_color(button_text_pixel_colorb), .text_pixel_addr(again_pixel_addr), .text_pixel_out(again_text_pixel));
    
endmodule

module text_display #(parameter TEXT_X,
                                TEXT_Y,
                                TEXT_WIDTH,
                                TEXT_HEIGHT,
                                ADDR_WIDTH,
                                SCALE_POWER = 0,
                                TEXT_COLOR = 12'hFFF,
                                WORD_INDEX = 0)
                     (input clk_in,
                      input [11:0] hcount_in, hcount1, hcount2, hcount4,
                      input [10:0] vcount_in,
                      input text_pixel_color,
                      output logic [ADDR_WIDTH - 1:0] text_pixel_addr,
                      output logic [11:0] text_pixel_out

    );
    
    logic [$clog2(TEXT_WIDTH) - 1:0] part_row;
    logic [$clog2(TEXT_HEIGHT) - 1:0] num_full_rows;
    logic [ADDR_WIDTH - 1:0] full_rows;
    
    always_ff @ (posedge clk_in) begin
        num_full_rows <= (vcount_in - TEXT_Y) >> SCALE_POWER;
        
        part_row <= (hcount1 - TEXT_X) >> SCALE_POWER;      
        full_rows <= num_full_rows * TEXT_WIDTH;
        
        if (hcount2 >= TEXT_X && hcount2 < TEXT_X + (TEXT_WIDTH << SCALE_POWER) &&
          vcount_in >= TEXT_Y && vcount_in < TEXT_Y + (TEXT_HEIGHT << SCALE_POWER)) begin
            text_pixel_addr <= part_row + full_rows + WORD_INDEX * TEXT_WIDTH * TEXT_HEIGHT;
        end else text_pixel_addr <= 0;
        
        if (hcount4 >= TEXT_X && hcount4 < TEXT_X + (TEXT_WIDTH << SCALE_POWER) &&
          vcount_in >= TEXT_Y && vcount_in < TEXT_Y + (TEXT_HEIGHT << SCALE_POWER)) begin
            case(text_pixel_color)
                0: text_pixel_out <= 0;
                1: text_pixel_out <= TEXT_COLOR;
            endcase
        end else text_pixel_out <= 0;
    end
    
endmodule
