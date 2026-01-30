`timescale 1ns / 1ps

module sd_to_fifo(  input clk_in,
                    input reset_in,
                    input load_fifo,
                    input [31:0] read_addr,
                    input sd_read_accepted,
                    input sd_byte_available,
                    input [7:0] sd_dout,
                    output logic request_sd_read,
                    output logic [31:0] sd_addr,
                    output logic [7:0] fifo_din,
                    output logic fifo_write_enable

    );
    
    parameter IDLE = 0;
    parameter REQUEST_READ_WAIT = 1;
    parameter WRITE_BYTES = 2;
    
    logic [1:0] state;
    logic [9:0] byte_count;
    logic sd_byte_available_old;
    
    always_ff @(posedge clk_in) begin
        sd_byte_available_old <= sd_byte_available;
        if (reset_in) begin
            request_sd_read <= 0;
            fifo_write_enable <= 0;
            byte_count <= 0;
            state <= IDLE;
        end else case(state)
            IDLE: begin
                if (load_fifo) begin
                    state <= REQUEST_READ_WAIT;
                    request_sd_read <= 1;
                    sd_addr <= read_addr;
                end else state <= IDLE;
            end
            REQUEST_READ_WAIT: begin
                if (sd_read_accepted) begin
                    request_sd_read <= 0;
                    state <= WRITE_BYTES;
                    byte_count <= 0;
                end else state <= REQUEST_READ_WAIT;
            end
            WRITE_BYTES: begin
                if (~sd_byte_available_old & sd_byte_available) begin
                    fifo_write_enable <= 1;
                    fifo_din <= sd_dout;
                    byte_count <= byte_count + 1;
                end else begin
                    fifo_write_enable <= 0;
                    state <= (byte_count == 512) ? IDLE : WRITE_BYTES;
                end
            end
        endcase
    end

endmodule