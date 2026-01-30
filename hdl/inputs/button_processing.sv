`timescale 1ns / 1ps

module button_processing( input clk_in,
                          input reset_in,
                          input btnc, btnu, btnd, btnl, btnr,
                          output logic reset_b,
                          output logic select_b,
                          output logic pause_b,
                          output logic up_b,
                          output logic down_b,
                          output logic left_b,
                          output logic right_b,
                          output logic rotate_b,
                          output logic hard_drop_b,
                          output logic soft_drop_b,
                          output logic hold_b

    );
    
    logic center, up, down, left, right;
    logic center_short_pulse, center_medium_pulse, center_long_pulse, up_pulse, 
      hard_drop_pulse, soft_drop_pulse, left_pulse, right_pulse;
    
    debounce db1(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(btnc), .clean_out(center));
    debounce db2(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(btnu), .clean_out(up));
    debounce db3(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(btnd), .clean_out(down));
    debounce db4(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(btnl), .clean_out(left));
    debounce db5(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(btnr), .clean_out(right));

    button_sharing btn_share1(.clk_in(clk_in), .level_in(center), .short_pulse_out(center_short_pulse), 
      .medium_pulse_out(center_medium_pulse), .long_pulse_out(center_long_pulse));
    level_to_pulse ltp1(.clk_in(clk_in), .level_in(up), .pulse_out(up_pulse));
    dual_drop dd1(.clk_in(clk_in), .reset_in(reset_in), .level_in(down), 
      .hard_drop_pulse_out(hard_drop_pulse), .soft_drop_pulse_out(soft_drop_pulse));
    auto_shift auto_shift1(.clk_in(clk_in), .reset_in(reset_in), .level_in(left), .pulse_out(left_pulse));
    auto_shift auto_shift2(.clk_in(clk_in), .reset_in(reset_in), .level_in(right), .pulse_out(right_pulse));
    
    always_comb begin
        reset_b = center_long_pulse;
        select_b = center_short_pulse | center_medium_pulse;
        pause_b = center_medium_pulse;
        up_b = up_pulse;
        down_b = soft_drop_pulse | hard_drop_pulse;
        left_b = left_pulse;
        right_b = right_pulse;
        rotate_b = up_pulse;
        hard_drop_b = hard_drop_pulse;
        soft_drop_b = soft_drop_pulse;
        hold_b = center_short_pulse;
    end
        
endmodule