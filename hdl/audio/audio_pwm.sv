`timescale 1ns / 1ps

module audio_pwm(   input clk_in,		
                    input reset_in,
                    input [7:0] audio_data,
                    output logic pwm_out
    
    );
    
    parameter PWM_PERIOD = 371;//400 kHz pwm signal
    
    logic [8:0] pwm_counter;
       
    always @(posedge clk_in) begin
        if (reset_in) begin
            pwm_counter <= 0;
            pwm_out <= 0;
        end else begin
            pwm_counter <= (pwm_counter == PWM_PERIOD - 1) ? 0 : pwm_counter + 1;
            if (pwm_counter >= audio_data)
                pwm_out <= 0;
            else pwm_out <= 1;
        end
    end
    
endmodule