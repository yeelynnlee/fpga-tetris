`timescale 1ns / 1ps

module level_to_pulse(  input clk_in,
                        input level_in,
                        output logic pulse_out

    );
    
    logic old_level;
 
    always_ff @(posedge clk_in) begin
        old_level <= level_in;
        pulse_out <= level_in & ~old_level;
    end
    
endmodule

module button_sharing(  input clk_in,
                        input level_in,
                        output logic short_pulse_out,
                        output logic medium_pulse_out,
                        output logic long_pulse_out

    );
    
    parameter MEDIUM_PRESS_MIN = 29700000;//200 ms
    parameter LONG_PRESS_MIN = 445500000;//3 s
    
    logic old_level;
    logic [28:0] count;
    
    always_ff @(posedge clk_in) begin
        old_level <= level_in;
        short_pulse_out <= (count < MEDIUM_PRESS_MIN) ? ~level_in & old_level : 0;
        medium_pulse_out <= (count == MEDIUM_PRESS_MIN);
        long_pulse_out <= (count == LONG_PRESS_MIN);
        if (level_in & ~old_level)
            count <= 0;
        else if (level_in & old_level)
            count <= (count <= LONG_PRESS_MIN) ? count + 1 : count;
        else if (~level_in & old_level)
            count <= 0;     
    end
    
endmodule

module dual_drop(   input clk_in,
                    input reset_in,
                    input level_in,
                    output logic hard_drop_pulse_out,
                    output logic soft_drop_pulse_out

    );
    
    parameter SOFT_DROP_MIN_PRESS = 29700000;//200 ms
    parameter SOFT_DROP_SPEED = 7425000;//50 ms
    
    logic old_level;
    logic [24:0] wait_count;
    logic soft_drop_enable;
    logic [22:0] drop_count;
    
    always_ff @(posedge clk_in) begin
        old_level <= level_in;
        hard_drop_pulse_out <= (wait_count < SOFT_DROP_MIN_PRESS) ? ~level_in & old_level : 0;
        soft_drop_pulse_out <= (wait_count == SOFT_DROP_MIN_PRESS) | (drop_count == SOFT_DROP_SPEED);
        if (reset_in) begin
            wait_count <= 0;
            soft_drop_enable <= 0;
            drop_count <= 0;
        end else if (level_in & old_level) begin
            if (soft_drop_enable) begin
                if (drop_count == SOFT_DROP_SPEED)
                    drop_count <= 0;
                else drop_count <= drop_count + 1;
            end else if (wait_count > SOFT_DROP_MIN_PRESS) begin
                soft_drop_enable <= 1;
            end else wait_count <= wait_count + 1;
        end else if (~level_in & old_level) begin
            wait_count <= 0;
            soft_drop_enable <= 0;
            drop_count <= 0;
        end  
    end
    
endmodule

module soft_drop(   input clk_in,
                    input reset_in,
                    input level_in,
                    output logic pulse_out

    );
    
    parameter SOFT_DROP_SPEED = 7425000;//50 ms
    
    logic old_level;
    logic [22:0] count;
    
    always_ff @(posedge clk_in) begin
        old_level <= level_in;
        pulse_out <= (level_in & ~old_level) | (count == SOFT_DROP_SPEED);
        if (reset_in) begin
            count <= 0;
        end else if (level_in & old_level) begin
            if (count == SOFT_DROP_SPEED)
                count <= 0;
            else count <= count + 1;
        end else if (~level_in & old_level)
            count <= 0;    
    end
    
endmodule

module auto_shift(  input clk_in,
                    input reset_in,
                    input level_in,
                    output logic pulse_out

    );
    
    parameter AUTO_SHIFT_DELAY = 25245000;//170 ms
    parameter AUTO_SHIFT_SPEED = 7425000;//50 ms
    
    logic old_level;
    logic [24:0] wait_count;
    logic auto_shift_enable;
    logic [22:0] auto_count;
    
    always_ff @(posedge clk_in) begin
        old_level <= level_in;
        pulse_out <= (level_in & ~old_level) | 
          (wait_count == AUTO_SHIFT_DELAY) | (auto_count == AUTO_SHIFT_SPEED);
        if (reset_in) begin
            wait_count <= 0;
            auto_shift_enable <= 0;
            auto_count <= 0;
        end else if (level_in & old_level) begin
            if (auto_shift_enable) begin
                if (auto_count == AUTO_SHIFT_SPEED)
                    auto_count <= 0;
                else auto_count <= auto_count + 1;
            end else if (wait_count == AUTO_SHIFT_DELAY) begin
                wait_count <= 0;
                auto_shift_enable <= 1;
            end else wait_count <= wait_count + 1; 
        end else if (~level_in & old_level) begin
            wait_count <= 0;
            auto_shift_enable <=0;
            auto_count <= 0; 
        end     
    end
    
endmodule