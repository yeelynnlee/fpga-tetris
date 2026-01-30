`timescale 1ns / 1ps

module top_level(   input clk_100mhz,
                    input btnc, btnu, btnl, btnr, btnd,
                    input ps2_clk, ps2_data,
                    input sd_cd, sd_dat0,
                    output logic sd_dat1, sd_dat2, sd_dat3,
                    output logic sd_reset, 
                    output logic sd_sck, 
                    output logic sd_cmd,
                    output aud_sd,
                    output aud_pwm,
                    output [3:0] vga_r,
                    output [3:0] vga_b,
                    output [3:0] vga_g,
                    output vga_hs,
                    output vga_vs
                    
    );
    
    clk_wiz clocks(.clk_in1(clk_100mhz), .clk_out1(clk_148_5mhz), .clk_out2(clk_25mhz));

    logic reset, select, pause, up, down, left, right, rotate, hard_drop, soft_drop, hold;
    
    logic reset_b, select_b, pause_b, up_b, down_b, left_b, right_b, 
      rotate_b, hard_drop_b, soft_drop_b, hold_b;
    button_processing btns(.clk_in(clk_148_5mhz), .reset_in(reset),
      .btnc(btnc), .btnu(btnu), .btnd(btnd), .btnl(btnl), .btnr(btnr),
      .reset_b(reset_b), .select_b(select_b), .pause_b(pause_b), 
      .up_b(up_b), .down_b(down_b), .left_b(left_b), .right_b(right_b),
      .rotate_b(rotate_b), .hard_drop_b(hard_drop_b), .soft_drop_b(soft_drop_b), .hold_b(hold_b));
    
    logic [7:0] keyboard_data;
    logic new_data_received;
    logic reset_k, select_k, pause_k, up_k, down_k, left_k, right_k, 
      rotate_k, hard_drop_k, soft_drop_k, hold_k;
    ps2_interface keyboard(.clk_in(clk_148_5mhz), .reset_in(reset), 
      .ps2_clk(ps2_clk), .ps2_data(ps2_data), 
      .data_out(keyboard_data), .new_data_received(new_data_received));
    key_processing keys(.clk_in(clk_148_5mhz), .reset_in(reset),
      .keyboard_data(keyboard_data), .new_data_received(new_data_received),
      .reset_k(reset_k), .select_k(select_k), .pause_k(pause_k), 
      .up_k(up_k), .down_k(down_k), .left_k(left_k), .right_k(right_k),
      .rotate_k(rotate_k), .hard_drop_k(hard_drop_k), .soft_drop_k(soft_drop_k), .hold_k(hold_k));
    
    always_comb begin
        reset = reset_b | reset_k;
        select = select_b | select_k;
        pause = pause_b | pause_k;
        up = up_b | up_k;
        down = down_b | down_k;
        left = left_b | left_k;
        right = right_b | right_k;
        rotate = rotate_b | rotate_k;
        hard_drop = hard_drop_b | hard_drop_k;
        soft_drop = soft_drop_b | soft_drop_k;
        hold = hold_b | hold_k;
    end
    
    logic [11:0] hcount;
    logic [10:0] vcount;
    logic hsync, vsync, blank;   
    xvga xvga1(.vclock_in(clk_148_5mhz),.hcount_out(hcount),.vcount_out(vcount),
       .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));
    
    logic [11:0] pixel;
    logic thsync, tvsync, tblank;
    logic [5:0] game_state;
    logic pause_bgm;
    logic [1:0] sound_effect;
    
    tetris_game tg(.clk_in(clk_148_5mhz), .reset_in(reset), .select_in(select), .pause_in(pause),
      .up_in(up), .down_in(down), .left_in(left), .right_in(right), .rotate_in(rotate),
      .hard_drop_in(hard_drop), .soft_drop_in(soft_drop), .hold_in(hold),
      .hcount_in(hcount), .vcount_in(vcount), .hsync_in(hsync), .vsync_in(vsync), .blank_in(blank),
      .thsync_out(thsync), .tvsync_out(tvsync), .tblank_out(tblank), .pixel_out(pixel),
      .game_state(game_state), .pause_bgm(pause_bgm), .sound_effect(sound_effect));
    
    logic [7:0] bgm_audio;
    logic [7:0] sfx_audio;
    sd_manager(.sys_clk_in(clk_148_5mhz), .sd_clk_in(clk_25mhz), .reset_in(reset),
      .game_state(game_state), .pause_bgm(pause_bgm), .sound_effect(sound_effect),
      .sd_cd(sd_cd), .sd_dat0(sd_dat0), .sd_dat1(sd_dat1), .sd_dat2(sd_dat2), 
      .sd_dat3(sd_dat3), .sd_reset(sd_reset), .sd_sck(sd_sck), .sd_cmd(sd_cmd), 
      .bgm_audio(bgm_audio), .sfx_audio(sfx_audio));
      
    logic [9:0] comb_audio;
    logic [7:0] pwm_audio;
    logic pwm_value;
    
    assign comb_audio = sfx_audio + bgm_audio;
    assign pwm_audio = (comb_audio > 8'hFF) ? 8'hFF : comb_audio[7:0];
    
    audio_pwm(.clk_in(clk_148_5mhz), .reset_in(reset), .audio_data(pwm_audio),
      .pwm_out(pwm_value));
    
    assign aud_sd = 1'b1;
    assign aud_pwm = pwm_value ? 1'bZ : 1'b0;
    
    logic [11:0] rgb;
    logic hs, vs, b;
    always_ff @(posedge clk_148_5mhz) begin
         rgb <= pixel;
         hs <= thsync;
         vs <= tvsync;
         b <= tblank;
    end

    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;
    
endmodule