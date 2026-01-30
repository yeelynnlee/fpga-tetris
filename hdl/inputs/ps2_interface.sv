`timescale 1ns / 1ps

module ps2_interface(   input clk_in,
                        input reset_in,
                        input ps2_clk,
                        input ps2_data,
                        output logic [7:0] data_out,
                        output logic new_data_received
                        
    );
    
    parameter WAITING = 0;
    parameter RECEIVING = 1;
    parameter ERROR_CHECKING = 2;
    
    logic keyboard_clk, keyboard_data;
    logic [1:0] state;
    logic keyboard_clk_old;
    logic falling_clk_edge, rising_clk_edge;
    logic [9:0] new_data;
    logic [12:0] count;
    logic data_parity;
    
    synchronize sync1(.clk_in(clk_in), .in(ps2_clk), .out(ps2_clk_sync));
    synchronize sync2(.clk_in(clk_in), .in(ps2_data), .out(ps2_data_sync));
    
    debounce #(.NUM_CYCLES(743))//5 us 
       db1 (.clk_in(clk_in), .reset_in(reset_in), .noisy_in(ps2_clk_sync), .clean_out(keyboard_clk));
    debounce #(.NUM_CYCLES(743))
       db2 (.clk_in(clk_in), .reset_in(reset_in), .noisy_in(ps2_data_sync), .clean_out(keyboard_data));
    
    assign falling_clk_edge = keyboard_clk_old & ~keyboard_clk;
    assign rising_clk_edge = ~keyboard_clk_old & keyboard_clk;
    
    assign data_parity = new_data[8] ^ new_data[7] ^ new_data[6] ^ new_data[5] ^ 
      new_data[4] ^ new_data[3] ^ new_data[2] ^ new_data[1] ^ new_data[0];
    
    always_ff @(posedge clk_in) begin
        keyboard_clk_old <= keyboard_clk;
        if (reset_in) begin
            new_data <= 0;
            count <= 0;
            data_out <= 0;
            new_data_received <= 0;
            state <= WAITING;
        end else case(state)
            WAITING: begin
                new_data_received <= 0;
                if ((falling_clk_edge) && (~keyboard_data))
                    state <= RECEIVING;
            end
            RECEIVING: begin
                if (falling_clk_edge)
                    new_data <= {keyboard_data, new_data[9:1]};
                else if (rising_clk_edge)
                    count <= 0;
                else if (keyboard_clk) begin
                    if (count == 8168)//55 us
                        state <= ERROR_CHECKING;
                    else count <= count + 1;
                end
            end
            ERROR_CHECKING: begin
                if ((new_data[9]) && (data_parity)) begin
                    data_out <= new_data[7:0];
                    new_data_received <= 1;
                end
                state <= WAITING;
                new_data <= 0;
            end
        endcase
    end
    
endmodule