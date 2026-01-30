`timescale 1ns / 1ps

module box_pixel(   input clk_in,
                    input [11:0] hcount4,
                    input [10:0] vcount_in,
                    output [11:0] start_box_pixel,
                    output [11:0] start_blink_box_pixel,
                    output [11:0] grid_outline_pixel, 
                    output [11:0] score_box_pixel,
                    output logic [11:0] score_divider_pixel,
                    output [11:0] next_outer_box_pixel,
                    output [11:0] next_inner_box_pixel,   
                    output [11:0] hold_outer_box_pixel,
                    output [11:0] hold_inner_box_pixel,
                    output [11:0] popup_box_pixel,
                    output [11:0] popup_solid_box_pixel,
                    output [11:0] option1_box_pixel,
                    output [11:0] option1_select_box_pixel,
                    output [11:0] option2_box_pixel,
                    output [11:0] option2_select_box_pixel

    );

    parameter WHITE_RGB = 12'hFFF;
    parameter GREY_RGB = 12'h555;
    
    box_display #(.BOX_START_X(384), .BOX_END_X(819), .BOX_START_Y(619), .BOX_END_Y(790))
       start_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(start_box_pixel));
    
    box_display #(.BOX_START_X(384), .BOX_END_X(819), .BOX_START_Y(619), .BOX_END_Y(790), .BOX_COLOR(WHITE_RGB))
       start_blink_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(start_blink_box_pixel));
    
    box_display #(.BOX_START_X(799), .BOX_END_X(1120), .BOX_START_Y(329), .BOX_END_Y(970))
       grid_outline(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(grid_outline_pixel));
    
    box_display #(.BOX_START_X(448), .BOX_END_X(735), .BOX_START_Y(434), .BOX_END_Y(865))
       score_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(score_box_pixel));
    
    parameter SCORE_BOX_DIVIDER_START_X = 464;
    parameter SCORE_BOX_DIVIDER_END_X = 719;
    parameter SCORE_BOX_DIVIDER_Y1 = 578;
    parameter SCORE_BOX_DIVIDER_Y2 = 722;
    
    always_ff @ (posedge clk_in) begin
        if ((hcount4 >= SCORE_BOX_DIVIDER_START_X && hcount4 <= SCORE_BOX_DIVIDER_END_X) &&
          (vcount_in == SCORE_BOX_DIVIDER_Y1 || vcount_in == SCORE_BOX_DIVIDER_Y2))
            score_divider_pixel <= GREY_RGB;
        else score_divider_pixel <= 0;
    end
    
    box_display #(.BOX_START_X(1184), .BOX_END_X(1375), .BOX_START_Y(402), .BOX_END_Y(577))
       next_outer_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(next_outer_box_pixel));
    
    box_display #(.BOX_START_X(1199), .BOX_END_X(1360), .BOX_START_Y(465), .BOX_END_Y(562))
       next_inner_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(next_inner_box_pixel));
    
    box_display #(.BOX_START_X(1184), .BOX_END_X(1375), .BOX_START_Y(722), .BOX_END_Y(897))
       hold_outer_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(hold_outer_box_pixel));
       
    box_display #(.BOX_START_X(1199), .BOX_END_X(1360), .BOX_START_Y(785), .BOX_END_Y(882))
       hold_inner_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(hold_inner_box_pixel));  
    
    box_display #(.BOX_START_X(766), .BOX_END_X(1153), .BOX_START_Y(511), .BOX_END_Y(788))
       popup_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(popup_box_pixel));
    
    solid_box_display #(.BOX_START_X(766), .BOX_END_X(1153), .BOX_START_Y(511), .BOX_END_Y(788))
       popup_solid_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .solid_box_pixel_out(popup_solid_box_pixel));
    
    box_display #(.BOX_START_X(825), .BOX_END_X(1094), .BOX_START_Y(611), .BOX_END_Y(675))
       option1_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(option1_box_pixel)); 
    
    box_display #(.BOX_START_X(825), .BOX_END_X(1094), .BOX_START_Y(611), .BOX_END_Y(675), .BOX_COLOR(WHITE_RGB))
       option1_select_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(option1_select_box_pixel));
    
    box_display #(.BOX_START_X(825), .BOX_END_X(1094), .BOX_START_Y(696), .BOX_END_Y(760))
       option2_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(option2_box_pixel));
    
    box_display #(.BOX_START_X(825), .BOX_END_X(1094), .BOX_START_Y(696), .BOX_END_Y(760), .BOX_COLOR(WHITE_RGB))
       option2_select_box(.clk_in(clk_in), .hcount4(hcount4), .vcount_in(vcount_in), 
       .box_pixel_out(option2_select_box_pixel));
       
endmodule

module box_display #(parameter BOX_START_X,
                               BOX_END_X,
                               BOX_START_Y,
                               BOX_END_Y,
                               BOX_COLOR = 12'h555)
                    (input clk_in,
                     input [11:0] hcount4,
                     input [10:0] vcount_in,
                     output logic [11:0] box_pixel_out 

    );
    
    always_ff @ (posedge clk_in) begin
        if ((hcount4 >= BOX_START_X && hcount4 <= BOX_END_X) && 
          (vcount_in == BOX_START_Y || vcount_in == BOX_END_Y) ||
          (vcount_in >= BOX_START_Y && vcount_in <= BOX_END_Y) && 
          (hcount4 == BOX_START_X || hcount4 == BOX_END_X))
            box_pixel_out <= BOX_COLOR;
        else box_pixel_out <= 0;
    end
    
endmodule

module solid_box_display #(parameter BOX_START_X,
                                     BOX_END_X,
                                     BOX_START_Y,
                                     BOX_END_Y,
                                     BOX_COLOR = 12'h111)
                          (input clk_in,
                           input [11:0] hcount4,
                           input [10:0] vcount_in,
                           output logic [11:0] solid_box_pixel_out

    );
    
    always_ff @ (posedge clk_in) begin
        if ((hcount4 >= BOX_START_X && hcount4 <= BOX_END_X) && 
          (vcount_in >= BOX_START_Y && vcount_in <= BOX_END_Y))
            solid_box_pixel_out <= BOX_COLOR;
        else solid_box_pixel_out <= 0;
    end
    
endmodule