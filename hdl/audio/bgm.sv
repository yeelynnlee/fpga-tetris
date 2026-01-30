`timescale 1ns / 1ps

module bgm( input clk_in,
            input reset_in,
            input [5:0] game_state,
            input pause_bgm,
            input sd_read_accepted,
            input sd_byte_available,
            input [7:0] sd_dout,
            output logic request_sd_read,
            output logic [31:0] sd_addr,
            output logic [7:0] audio_out

    );
    
    parameter RESET = 1;
    
    parameter SAMPLE_LENGTH = 3367;//44.1 kHz sampling rate
    
    parameter BGM_START_ADDR = 4200000;
    parameter BGM_END_ADDR = 4203306;
    
    parameter IDLE = 0;
    parameter CLEAR_FIFO = 1;
    parameter LOAD_FIFO_WAIT = 2;
    parameter READ_FIFO_WAIT = 3;
    parameter PLAY_MUSIC = 4;
    parameter PAUSE_MUSIC = 5;
    
    logic [2:0] state;
    logic load_fifo;
    logic [31:0] read_addr;
    logic [9:0] fifo_read_count;
    logic [11:0] count;
    
    logic [7:0] fifo_din;
    logic fifo_write_enable;
    logic fifo_read_enable;
    logic [7:0] fifo_dout;
    logic fifo_empty;
    
    audio_fifo bgm_audio(.clk(clk_in), .srst(reset_in), .din(fifo_din), .wr_en(fifo_write_enable), 
      .rd_en(fifo_read_enable), .dout(fifo_dout), .empty(fifo_empty));
    
    sd_to_fifo stf1(.clk_in(clk_in), .reset_in(reset_in), .load_fifo(load_fifo), .read_addr(read_addr),
       .sd_read_accepted(sd_read_accepted), .sd_byte_available(sd_byte_available), .sd_dout(sd_dout), 
       .request_sd_read(request_sd_read), .sd_addr(sd_addr), .fifo_din(fifo_din), .fifo_write_enable(fifo_write_enable));
    
    always_ff @(posedge clk_in) begin
        if (reset_in) begin
            audio_out <= 0;
            load_fifo <= 0;
            fifo_read_enable <= 0;
            fifo_read_count <= 0;
            count <= 0;
            state <= IDLE;
        end else if (game_state == RESET) begin
            state <= CLEAR_FIFO;
            fifo_read_enable <= (fifo_empty) ? 0 : 1;
        end else case(state)
            IDLE: begin
            end
            CLEAR_FIFO: begin
                if (fifo_empty) begin
                    fifo_read_enable <= 0;
                    load_fifo <= 1;
                    read_addr <= BGM_START_ADDR;
                    state <= LOAD_FIFO_WAIT;
                end else state <= CLEAR_FIFO;
            end
            LOAD_FIFO_WAIT: begin
                load_fifo <= 0;
                if (!fifo_empty) begin
                    fifo_read_enable <= 1;
                    fifo_read_count <= 0;
                    state <= READ_FIFO_WAIT;
                end else state <= LOAD_FIFO_WAIT;
            end
            READ_FIFO_WAIT: begin
                fifo_read_enable <= 0;
                fifo_read_count <= (fifo_read_count == 512) ? 1 : fifo_read_count + 1;
                state <= PLAY_MUSIC;
                count <= 0;
                if (fifo_read_count == 496) begin
                    load_fifo <= 1;
                    read_addr <= (read_addr == BGM_END_ADDR) ? BGM_START_ADDR : read_addr + 1;
                end
            end
            PLAY_MUSIC: begin
                load_fifo <= 0;
                audio_out <= fifo_dout;
                if (pause_bgm) begin
                    state <= PAUSE_MUSIC;
                end else if (count == SAMPLE_LENGTH) begin
                    fifo_read_enable <= 1;
                    state <= READ_FIFO_WAIT;
                end else count <= count + 1;
            end
            PAUSE_MUSIC: begin
                audio_out <= 0;
                state <= (pause_bgm) ? PAUSE_MUSIC : PLAY_MUSIC;
            end
        endcase
    end     
    
endmodule