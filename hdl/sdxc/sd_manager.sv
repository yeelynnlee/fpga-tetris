`timescale 1ns / 1ps

module sd_manager(  input sys_clk_in,
                    input sd_clk_in,
                    input reset_in,
                    input [5:0] game_state,
                    input pause_bgm,
                    input [1:0] sound_effect,
                    input sd_cd, sd_dat0,
                    output sd_dat1, sd_dat2, sd_dat3,
                    output sd_reset,
                    output sd_sck,
                    output sd_cmd,
                    output [7:0] bgm_audio,
                    output [7:0] sfx_audio

    );
    
    assign sd_dat1 = 1;
    assign sd_dat2 = 1;
    assign sd_reset = 0;
    
    // sd_controller inputs
    logic rd;                   // read enable
    logic wr;                   // write enable
    logic [7:0] din;            // data to sd card
    logic [31:0] addr;          // SECTOR address for read/write operation
    
    // sd_controller outputs
    logic ready;                // high when ready for new read/write operation
    logic [7:0] dout;           // data from sd card
    logic byte_available;       // high when byte available for read
    logic ready_for_next_byte;  // high when ready for new byte to be written
    
    // handles reading from the SD card
    sd_controller sd(.reset(reset_in), .clk(sd_clk_in), .cs(sd_dat3), .mosi(sd_cmd), 
                     .miso(sd_dat0), .sclk(sd_sck), .ready(ready), .address(addr),
                     .rd(rd), .dout(dout), .byte_available(byte_available),
                     .wr(wr), .din(din), .ready_for_next_byte(ready_for_next_byte));
    
    logic sd_ready;
    logic sd_byte_available;
    logic [7:0] sd_dout;
    
    synchronize sync1(.clk_in(sys_clk_in), .in(ready), .out(sd_ready));
    synchronize sync2(.clk_in(sys_clk_in), .in(byte_available), .out(sd_byte_available));
    synchronize #(.DATA_WIDTH(8)) sync3(.clk_in(sys_clk_in), .in(dout), .out(sd_dout));
    
    logic bgm_read_requested;
    logic [31:0] bgm_addr;
    logic bgm_read_accepted;
    
    bgm bgm1(.clk_in(sys_clk_in), .reset_in(reset_in), .game_state(game_state), 
      .pause_bgm(pause_bgm), .sd_read_accepted(bgm_read_accepted), 
      .sd_byte_available(sd_byte_available), .sd_dout(sd_dout), 
      .request_sd_read(bgm_read_requested), .sd_addr(bgm_addr),
      .audio_out(bgm_audio));
    
    logic sfx_read_requested;
    logic [31:0] sfx_addr;
    logic sfx_read_accepted;
    
    sound_fx sfx1(.clk_in(sys_clk_in), .reset_in(reset_in), .sound_effect(sound_effect), 
      .sd_read_accepted(sfx_read_accepted), .sd_byte_available(sd_byte_available), 
      .sd_dout(sd_dout), .request_sd_read(sfx_read_requested), .sd_addr(sfx_addr),
      .audio_out(sfx_audio));
    
    parameter IDLE = 0;
    parameter HOLD_READ = 1;
    
    logic state;
    logic read_sd;
    
    synchronize sync4(.clk_in(sd_clk_in), .in(read_sd), .out(rd));
    
    always_ff @(posedge sys_clk_in) begin
        if (reset_in) begin
            read_sd <= 0;
            bgm_read_accepted <= 0;
            sfx_read_accepted <= 0;
            state <= IDLE;
        end else case(state)
            IDLE: begin
                if (bgm_read_requested) begin
                    if (sd_ready) begin
                        bgm_read_accepted <= 1;
                        read_sd <= 1;
                        addr <= bgm_addr;
                        state <= HOLD_READ;
                    end else state <= IDLE;
                end else if (sfx_read_requested) begin
                    if (sd_ready) begin
                        sfx_read_accepted <= 1;
                        read_sd <= 1;
                        addr <= sfx_addr;
                        state <= HOLD_READ;
                    end else state <= IDLE;
                end else state <= IDLE;
            end
            HOLD_READ: begin
                if (!sd_ready) begin
                    read_sd <= 0;
                    bgm_read_accepted <= 0;
                    sfx_read_accepted <= 0;
                    state <= IDLE;
                end else state <= HOLD_READ;
            end
        endcase
    end
    
endmodule
