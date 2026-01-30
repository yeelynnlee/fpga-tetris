`timescale 1ns / 1ps

module key_processing(  input clk_in,
                        input reset_in,
                        input [7:0] keyboard_data,
                        input new_data_received,
                        output logic reset_k,
                        output logic select_k,
                        output logic pause_k,
                        output logic up_k,
                        output logic down_k,
                        output logic left_k,
                        output logic right_k,
                        output logic rotate_k,
                        output logic hard_drop_k,
                        output logic soft_drop_k,
                        output logic hold_k

    );
     parameter KEY_UP = 8'hF0;
     parameter ESC_KEY = 8'h76;
     parameter ENTER_KEY = 8'h5A;
     parameter SPACE_BAR = 8'h29;
     parameter C_KEY = 8'h21;
     parameter Z_KEY = 8'h1A;
     parameter UP_KEY = 8'h75;
     parameter DOWN_KEY = 8'h72;
     parameter LEFT_KEY = 8'h6B;
     parameter RIGHT_KEY = 8'h74;
     
     logic [7:0] prev_data;
     logic esc_key, enter_key, space_bar, c_key, z_key, up_key, down_key, left_key, right_key;
     
     always_ff @(posedge clk_in) begin
        if (reset_in) begin
            prev_data <= 0;
            esc_key <= 0;
            enter_key <= 0;
            space_bar <= 0;
            c_key <= 0;
            z_key <= 0;
            up_key <= 0;
            down_key <= 0;
            left_key <= 0;
            right_key <= 0;
        end else if (new_data_received) begin
            if (prev_data == KEY_UP) begin
                case(keyboard_data)
                    ESC_KEY: esc_key <= 0;
                    ENTER_KEY: enter_key <= 0;
                    SPACE_BAR: space_bar <= 0;
                    C_KEY: c_key <= 0;
                    Z_KEY: z_key <= 0;
                    UP_KEY: up_key <= 0;
                    DOWN_KEY: down_key <= 0;
                    LEFT_KEY: left_key <= 0;
                    RIGHT_KEY: right_key <= 0;
                endcase
            end else begin 
                case(keyboard_data)
                    ESC_KEY: esc_key <= 1;
                    ENTER_KEY: enter_key <= 1;
                    SPACE_BAR: space_bar <= 1;
                    C_KEY: c_key <= 1;
                    Z_KEY: z_key <= 1;
                    UP_KEY: up_key <= 1;
                    DOWN_KEY: down_key <= 1;
                    LEFT_KEY: left_key <= 1;
                    RIGHT_KEY: right_key <= 1;
                endcase
            end
            prev_data <= keyboard_data;
        end
    end
    
    logic esc, enter, space, c, z, up, down, left, right;
    debounce db1(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(esc_key), .clean_out(esc));
    debounce db2(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(enter_key), .clean_out(enter));
    debounce db3(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(space_bar), .clean_out(space));
    debounce db4(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(c_key), .clean_out(c));
    debounce db5(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(z_key), .clean_out(z));
    debounce db6(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(up_key), .clean_out(up));
    debounce db7(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(down_key), .clean_out(down));
    debounce db8(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(left_key), .clean_out(left));
    debounce db9(.clk_in(clk_in), .reset_in(reset_in), .noisy_in(right_key), .clean_out(right));
    
    level_to_pulse ltp2(.clk_in(clk_in), .level_in(esc), .pulse_out(esc_pulse));
    level_to_pulse ltp3(.clk_in(clk_in), .level_in(enter), .pulse_out(enter_pulse));
    level_to_pulse ltp4(.clk_in(clk_in), .level_in(space), .pulse_out(space_pulse));
    level_to_pulse ltp5(.clk_in(clk_in), .level_in(c), .pulse_out(c_pulse));
    level_to_pulse ltp6(.clk_in(clk_in), .level_in(z), .pulse_out(z_pulse));
    level_to_pulse ltp7(.clk_in(clk_in), .level_in(up), .pulse_out(up_pulse));
    auto_shift auto_shift3(.clk_in(clk_in), .reset_in(reset_in), .level_in(left), .pulse_out(left_pulse));
    auto_shift auto_shift4(.clk_in(clk_in), .reset_in(reset_in), .level_in(right), .pulse_out(right_pulse));
    soft_drop sd1(.clk_in(clk_in), .reset_in(reset_in), .level_in(down), 
.pulse_out(soft_drop_pulse));

    always_comb begin
        reset_k = esc_pulse;
        select_k = enter_pulse;
        pause_k = z_pulse;
        up_k = up_pulse;
        down_k = soft_drop_pulse;
        left_k = left_pulse;
        right_k = right_pulse;
        rotate_k = up_pulse;
        hard_drop_k = space_pulse;
        soft_drop_k = soft_drop_pulse;
        hold_k = c_pulse;
    end
    
endmodule
