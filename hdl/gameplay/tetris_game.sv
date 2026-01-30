`timescale 1ns / 1ps

module tetris_game( input clk_in,
                    input reset_in,
                    input select_in,
                    input pause_in,
                    input up_in,
                    input down_in,
                    input left_in,
                    input right_in,
                    input rotate_in,
                    input hard_drop_in,
                    input soft_drop_in,
                    input hold_in,
                    input [11:0] hcount_in,
                    input [10:0] vcount_in,
                    input hsync_in,
                    input vsync_in,
                    input blank_in,
                    
                    output logic thsync_out,
                    output logic tvsync_out,
                    output logic tblank_out,
                    output [11:0] pixel_out,
                    
                    output logic [5:0] game_state,
                    output logic pause_bgm,
                    output logic [1:0] sound_effect
                    
    );
    
    parameter RED = 3'b001;
    parameter ORANGE = 3'b010;
    parameter YELLOW = 3'b011;
    parameter GREEN = 3'b100;
    parameter BLUE = 3'b101;
    parameter PURPLE = 3'b110;
    parameter CYAN = 3'b111;
    
    parameter ROW_WIDTH = 10;
    parameter NUM_ROWS = 20;
    parameter ROW_START_X = 3;
    parameter ROW_START_Y = 1;
    parameter [3:0] MAP_WIDTH = 14;
    
    parameter BLOCK_X_START = 6;
    parameter BLOCK_Y_START = 0;

    parameter START_SCREEN = 0;
    parameter RESET = 1;
    parameter RESET_GRID = 2;
    parameter BLOCK_ADDR_WAIT = 3;
    parameter BLOCK_READ = 4;
    parameter BLOCK_READ_WAIT = 5;
    parameter BLOCK_CHECK = 6;
    parameter GHOST_WAIT = 7;
    parameter GHOST_CHECK = 8;
    parameter BLOCK_WRITE = 9;
    parameter GAME_PLAY = 10;
    parameter INCREMENT_SCORE = 11;
    parameter INCREMENT_SCORE_WAIT = 12;
    parameter PLACE_BLOCK = 13;
    parameter FALLING_SPECKS_ON = 14;
    parameter BLOCK_FLASH_ON = 15;
    parameter PLACE_FX_WAIT = 16;
    parameter FALLING_SPECKS_OFF = 17;
    parameter BLOCK_FLASH_OFF = 18;
    parameter ROW_READ = 19;
    parameter ROW_WAIT = 20;
    parameter ROW_CHECK = 21;
    parameter ROW_FLASH_ON = 22;
    parameter ROW_FLASH_ON_WAIT = 23;
    parameter ROW_FLASH_OFF = 24;
    parameter ROW_FLASH_OFF_WAIT = 25;
    parameter ROW_CLEAR = 26;
    parameter ROW_CLEAR_WAIT = 27;
    parameter ROW_SHIFT_READ = 28;
    parameter ROW_SHIFT_WAIT = 29;
    parameter ROW_SHIFT_WRITE = 30;
    parameter UPDATE_SCORE = 31;
    parameter SCORE_WAIT = 32;
    parameter GAME_PAUSE = 33;
    parameter GAME_OVER = 34;
    
    parameter NEW_BLOCK = 0;
    parameter FALL_DOWN = 1;
    parameter SOFT_DROP = 2;
    parameter HARD_DROP = 3;
    parameter ROTATE = 4;
    parameter MOVE_RIGHT = 5;
    parameter MOVE_LEFT = 6;
    parameter HOLD_SWITCH = 7;
    
    parameter LOCK_SOUND = 1;
    parameter CLEAR_SOUND = 2;
    
    logic [2:0] trigger;
    logic [2:0] block_color;
    logic [1:0] block_state;
    logic [3:0] block_x;
    logic [4:0] block_y;
    logic [8:0] curr_addr1, curr_addr2, curr_addr3, curr_addr4;
    logic [4:0] ghost_y;
    logic [8:0] ghost_addr1, ghost_addr2, ghost_addr3, ghost_addr4;
    logic [2:0] hold_block_color;

    logic [8:0] lines;
    logic [4:0] level;
    logic [23:0] score;
    
    logic start_blink;
    logic pause_select;
    logic game_over_select;
    
    logic [8:0] square_write_addr, square_read_addr;   
    logic [3:0] write_color, read_color;
    logic write_enable;
    square_map main_square_map(.clka(clk_in), .wea(write_enable), .addra(square_write_addr), .dina(write_color),
       .clkb(clk_in), .addrb(square_read_addr), .doutb(read_color));
    
    logic speck_enable;
    logic [8:0] speck_addr;
    logic speck;
    logic [4:0] speck_y;
    logic [8:0] speck_addr1, speck_addr2, speck_addr3, speck_addr4;
    
    logic flash_enable;
    logic [8:0] flash_addr;
    logic flash;
    
    logic [2:0] next_block_color;
    logic [11:0] block_buffer_addr;
    block_buffer_rom block_buffer(.clka(clk_in), .addra(block_buffer_addr), .douta(next_block_color));
    
    logic [31:0] lines_bcd;
    logic [31:0] level_bcd;
    logic [31:0] score_bcd;
       
    display display1(.clk_in(clk_in), .hcount_in(hcount_in), .vcount_in(vcount_in), 
       .hsync_in(hsync_in), .vsync_in(vsync_in), .blank_in(blank_in), .game_state(game_state),
       .start_blink(start_blink), .pause_select(pause_select), .game_over_select(game_over_select),
       .write_enable(write_enable), .square_write_addr(square_write_addr), .write_color(write_color), 
       .flash_enable(flash_enable), .flash_write_addr(flash_addr), .flash_write(flash),
       .speck_enable(speck_enable), .speck_write_addr(speck_addr), .speck_write(speck),
       .next_block_color(next_block_color), .hold_block_color(hold_block_color),
       .score_bcd(score_bcd), .level_bcd(level_bcd), .lines_bcd(lines_bcd),
       .thsync_out(thsync_out), .tvsync_out(tvsync_out), .tblank_out(tblank_out), .pixel_out(pixel_out));
    
    logic [8:0] fill_addr1, fill_addr2, fill_addr3, fill_addr4, fill_addr5, 
      fill_addr6, fill_addr7, fill_addr8, fill_addr9, fill_addr10;
    logic read_fill1, read_fill2, read_fill3, read_fill4, read_fill5, 
      read_fill6, read_fill7, read_fill8, read_fill9, read_fill10;
    logic fill_enable, write_fill;
    assign write_fill = (write_color) ? 1 : 0;
    fill_map fill_map1(.clka(clk_in), .wea(fill_enable), .addra(fill_addr1), .dina(write_fill), .douta(read_fill1));
    fill_map fill_map2(.clka(clk_in), .wea(fill_enable), .addra(fill_addr2), .dina(write_fill), .douta(read_fill2));
    fill_map fill_map3(.clka(clk_in), .wea(fill_enable), .addra(fill_addr3), .dina(write_fill), .douta(read_fill3));
    fill_map fill_map4(.clka(clk_in), .wea(fill_enable), .addra(fill_addr4), .dina(write_fill), .douta(read_fill4));
    fill_map fill_map5(.clka(clk_in), .wea(fill_enable), .addra(fill_addr5), .dina(write_fill), .douta(read_fill5));
    fill_map fill_map6(.clka(clk_in), .wea(fill_enable), .addra(fill_addr6), .dina(write_fill), .douta(read_fill6));
    fill_map fill_map7(.clka(clk_in), .wea(fill_enable), .addra(fill_addr7), .dina(write_fill), .douta(read_fill7));
    fill_map fill_map8(.clka(clk_in), .wea(fill_enable), .addra(fill_addr8), .dina(write_fill), .douta(read_fill8));
    fill_map fill_map9(.clka(clk_in), .wea(fill_enable), .addra(fill_addr9), .dina(write_fill), .douta(read_fill9));
    fill_map fill_map10(.clka(clk_in), .wea(fill_enable), .addra(fill_addr10), .dina(write_fill), .douta(read_fill10));
    
    logic [8:0] fill_addr;
    logic [8:0] read_addr1, read_addr2, read_addr3, read_addr4, read_addr5, 
      read_addr6, read_addr7, read_addr8, read_addr9, read_addr10;
    assign fill_addr1 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr1;
    assign fill_addr2 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr2;
    assign fill_addr3 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr3;
    assign fill_addr4 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr4;
    assign fill_addr5 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr5;
    assign fill_addr6 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr6;
    assign fill_addr7 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr7;
    assign fill_addr8 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr8;
    assign fill_addr9 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr9;
    assign fill_addr10 = (write_enable) ? square_write_addr : (fill_enable) ? fill_addr : read_addr10;
    
    logic [8:0] new_addr1, new_addr2, new_addr3, new_addr4;
    logic [2:0] new_block_color;
    logic [1:0] new_block_state;
    logic [3:0] new_block_x;
    logic [4:0] new_block_y;
    block_addresses new_addresses(.clk_in(clk_in), .block_color(new_block_color), .block_state(new_block_state), .block_x(new_block_x),
       .block_y(new_block_y), .addr1(new_addr1), .addr2(new_addr2), .addr3(new_addr3), .addr4(new_addr4));
    
    logic [27:0] fall_time;
    fall_time fall_time1(.clk_in(clk_in), .level(level), .fall_time(fall_time));
    logic [27:0] fall_count;
    logic fall_down;
    assign fall_down = (fall_count == fall_time);
    
    logic [2:0] kicks_tried;
    logic [3:0] kick_block_x;
    logic [4:0] kick_block_y;
    wall_kicks wall_kicks1(.block_color(block_color), .block_state(block_state), .block_x(block_x),
       .block_y(block_y), .kicks_tried(kicks_tried), .kick_block_x(kick_block_x), .kick_block_y(kick_block_y));                   
    
    logic [26:0] lock_count;
    logic [3:0] move_count;

    logic [4:0] soft_drop_points;
    logic increment;
    logic [31:0] bcd_inc;
    logic incrementer_busy;
    increment_bcd increment_score(.clk_in(clk_in), .game_state(game_state), .start(increment), 
       .bcd_in(score_bcd), .bcd_out(bcd_inc), .busy(incrementer_busy));
    
    logic [4:0] old_level;
    logic [3:0] line_count;
    logic [2:0] rows_cleared;
    logic calc_score;
    scoring scoring1(.clk_in(clk_in), .game_state(game_state), .start(calc_score), .rows_cleared(rows_cleared),
       .level(old_level), .soft_drop_points(soft_drop_points), .block_y(block_y), .ghost_y(ghost_y), .score(score));
    
    logic lines_converted, level_converted, score_converted;
    logic convert;
    logic [23:0] binary_in;
    logic [31:0] bcd_out;
    logic converter_busy;
    binary_to_bcd btb1(.clk_in(clk_in), .game_state(game_state), .start(convert), .binary_in(binary_in),
       .bcd_out(bcd_out), .busy(converter_busy));
    assign binary_in = (!lines_converted) ? lines : (!level_converted) ? level : 
      (!score_converted) ? score : 0;
    
    logic read_wait;
    
    logic [3:0] i;
    logic [4:0] j;
    
    logic [35:0] block_write_buffer;
    logic [35:0] ghost_write_buffer;
    logic [35:0] block_clear_buffer;
    logic [35:0] ghost_clear_buffer;
    
    logic [4:0] row_number;
    logic [19:0] cleared_rows_buffer;
    logic [19:0] temp_rows_buffer;
    logic flash_count;
    logic [26:0] wait_count;
    
    logic hold_used;
    logic game_over;
    
    always_ff @(posedge clk_in) begin
        if (reset_in) begin
            game_state <= START_SCREEN;
        end else case (game_state)
            START_SCREEN: begin
                block_buffer_addr <= block_buffer_addr + 1;
                wait_count <= (wait_count == 111375000) ? 0 : wait_count + 1;
                start_blink <= (wait_count == 111375000) ? ~start_blink : start_blink;
                if (select_in) begin
                    game_state <= RESET;
                end
            end
            RESET: begin
                game_over <= 0;
                hold_block_color <= 0;
                lines <= 0;
                level <= 1;
                line_count <= 0;
                lines_bcd <= 32'hAAAA_AAA0;
                level_bcd <= 32'hAAAA_AAA1;
                score_bcd <= 32'hAAAA_AAA0;
                pause_bgm <= 0;
                sound_effect <= 0;
                game_state <= RESET_GRID;
                i <= 0;
                j <= 0;
            end
            RESET_GRID: begin
                if (j <= NUM_ROWS) begin
                    write_enable <= 1;
                    fill_enable <= 1;
                    write_color <= 0;                   
                    square_write_addr <= (ROW_START_X + i) + j * MAP_WIDTH;
                    
                    speck_enable <= 1;
                    speck <= 0;
                    speck_addr <= (ROW_START_X + i) + j * MAP_WIDTH;
                    
                    flash_enable <= 1;
                    flash <= 0;
                    flash_addr <= (ROW_START_X + i) + j * MAP_WIDTH;
                    
                    i <= (i == ROW_WIDTH - 1) ? 0 : i + 1;
                    j <= (i == ROW_WIDTH - 1) ? j + 1 : j;
                end else begin
                    write_enable <= 0;
                    fill_enable <= 0;
                    speck_enable <= 0;
                    flash_enable <= 0;
                    game_state <= BLOCK_ADDR_WAIT;
                    trigger <= NEW_BLOCK;
                    new_block_color <= next_block_color;
                    new_block_state <= 0;
                    new_block_x <= BLOCK_X_START;
                    new_block_y <= (next_block_color == CYAN) ? BLOCK_Y_START + 1 : BLOCK_Y_START;
                    block_buffer_addr <= block_buffer_addr + 1;
                    fall_count <= 0;
                    lock_count <= 0;
                    move_count <= 0;
                    soft_drop_points <= 0;
                    hold_used <= 0;
                end
            end
            BLOCK_ADDR_WAIT: begin
                game_state <= BLOCK_READ;
            end
            BLOCK_READ: begin
                read_addr1 <= new_addr1;
                read_addr2 <= new_addr2;
                read_addr3 <= new_addr3;
                read_addr4 <= new_addr4;
                game_state <= BLOCK_READ_WAIT;
                read_wait <= 0;
            end
            BLOCK_READ_WAIT: begin
                read_wait <= ~read_wait;
                game_state <= (read_wait) ? BLOCK_CHECK : BLOCK_READ_WAIT;
            end
            BLOCK_CHECK: begin
                if (~read_fill1 & ~read_fill2 & ~read_fill3 & ~read_fill4) begin
                    if (trigger != HARD_DROP) begin
                        block_color <= new_block_color;
                        block_state <= new_block_state;
                        block_x <= new_block_x;
                        block_y <= new_block_y;
                        lock_count <= 0;
                    end
                    
                    curr_addr1 <= read_addr1;
                    curr_addr2 <= read_addr2;
                    curr_addr3 <= read_addr3;
                    curr_addr4 <= read_addr4;
                    
                    block_clear_buffer <= (trigger == NEW_BLOCK) ? 0 : {curr_addr1, curr_addr2, curr_addr3, curr_addr4};
                    block_write_buffer <= {read_addr1, read_addr2, read_addr3, read_addr4};
                    
                    if (trigger == FALL_DOWN || trigger == SOFT_DROP || trigger == HARD_DROP) begin
                        ghost_clear_buffer <= 0;
                        ghost_write_buffer <= 0;
                        if (trigger == HARD_DROP) begin
                            speck_y <= block_y + 1;
                            speck_addr1 <= curr_addr1 + MAP_WIDTH;
                            speck_addr2 <= curr_addr2 + MAP_WIDTH;
                            speck_addr3 <= curr_addr3 + MAP_WIDTH;
                            speck_addr4 <= curr_addr4 + MAP_WIDTH;
                        end
                        game_state <= BLOCK_WRITE;
                    end else begin
                        ghost_clear_buffer <= (trigger == NEW_BLOCK) ? 0 : {ghost_addr1, ghost_addr2, ghost_addr3, ghost_addr4};
                        ghost_y <= new_block_y;
                        read_addr1 <= read_addr1 + MAP_WIDTH;
                        read_addr2 <= read_addr2 + MAP_WIDTH;
                        read_addr3 <= read_addr3 + MAP_WIDTH;
                        read_addr4 <= read_addr4 + MAP_WIDTH;
                        game_state <= GHOST_WAIT;
                        read_wait <= 0;
                    end
                
                end else if (trigger == ROTATE && kicks_tried < 4) begin
                    new_block_x <= kick_block_x;
                    new_block_y <= kick_block_y;
                    kicks_tried <= kicks_tried + 1;
                    game_state <= BLOCK_ADDR_WAIT;
                end else if (trigger == NEW_BLOCK) begin
                    block_color <= new_block_color;
                    block_clear_buffer <= 0;
                    block_write_buffer <= {read_addr1 - MAP_WIDTH, read_addr2 - MAP_WIDTH, 
                      read_addr3 - MAP_WIDTH, read_addr4 - MAP_WIDTH};
                    ghost_clear_buffer <= 0;
                    ghost_write_buffer <= 0;
                    game_over <= 1;
                    game_state <= BLOCK_WRITE;
                end else if (trigger == HOLD_SWITCH) begin
                    block_color <= new_block_color;
                    block_clear_buffer <= {curr_addr1, curr_addr2, curr_addr3, curr_addr4};
                    block_write_buffer <= {read_addr1 - MAP_WIDTH, read_addr2 - MAP_WIDTH, 
                      read_addr3 - MAP_WIDTH, read_addr4 - MAP_WIDTH};
                    ghost_clear_buffer <= {ghost_addr1, ghost_addr2, ghost_addr3, ghost_addr4};
                    ghost_write_buffer <= 0;
                    game_over <= 1;
                    game_state <= BLOCK_WRITE;
                end else game_state <= GAME_PLAY;
            end
            GHOST_WAIT: begin
                read_wait <= ~read_wait;
                game_state <= (read_wait) ? GHOST_CHECK : GHOST_WAIT;
            end
            GHOST_CHECK: begin
                if (read_fill1 | read_fill2 | read_fill3 | read_fill4) begin
                    ghost_addr1 <= read_addr1 - MAP_WIDTH;
                    ghost_addr2 <= read_addr2 - MAP_WIDTH;
                    ghost_addr3 <= read_addr3 - MAP_WIDTH;
                    ghost_addr4 <= read_addr4 - MAP_WIDTH;
                    ghost_write_buffer <= {read_addr1 - MAP_WIDTH, read_addr2 - MAP_WIDTH, read_addr3 - MAP_WIDTH, read_addr4 - MAP_WIDTH};
                    game_state <= BLOCK_WRITE;
                end else begin
                    ghost_y <= ghost_y + 1;
                    read_addr1 <= read_addr1 + MAP_WIDTH;
                    read_addr2 <= read_addr2 + MAP_WIDTH;
                    read_addr3 <= read_addr3 + MAP_WIDTH;
                    read_addr4 <= read_addr4 + MAP_WIDTH;
                    game_state <= GHOST_WAIT;
                    read_wait <= 0;
                end
            end
            BLOCK_WRITE: begin
                if (ghost_clear_buffer) begin
                    write_enable <= 1;
                    write_color <= 0;
                    square_write_addr <= ghost_clear_buffer[8:0];
                    ghost_clear_buffer <= {9'b0, ghost_clear_buffer[35:9]};
                end else if (block_clear_buffer) begin
                    write_enable <= 1;
                    write_color <= 0;
                    square_write_addr <= block_clear_buffer[8:0];
                    block_clear_buffer <= {9'b0, block_clear_buffer[35:9]};
                end else if (ghost_write_buffer) begin
                    write_enable <= 1;
                    write_color <= {1'b1, block_color};
                    square_write_addr <= ghost_write_buffer[8:0];
                    ghost_write_buffer <= {9'b0, ghost_write_buffer[35:9]};
                end else if (block_write_buffer) begin
                    write_enable <= 1;
                    write_color <= block_color;
                    square_write_addr <= block_write_buffer[8:0];
                    block_write_buffer <= {9'b0, block_write_buffer[35:9]};
                end else begin
                    write_enable <= 0;
                    if (trigger == SOFT_DROP) begin
                        game_state <= INCREMENT_SCORE;
                    end else if (trigger == HARD_DROP) begin
                        block_write_buffer <= {curr_addr1, curr_addr2, curr_addr3, curr_addr4};
                        game_state <= PLACE_BLOCK;
                    end else if ((trigger == NEW_BLOCK || trigger == HOLD_SWITCH) && (game_over)) begin
                        game_state <= GAME_OVER;
                        game_over_select <= 0;
                        pause_bgm <= 1;
                    end else game_state <= GAME_PLAY;
                end
            end
            GAME_PLAY: begin
                fall_count <= (fall_down) ? 0 : fall_count + 1;
                lock_count <= lock_count + 1;
                if (pause_in) begin
                    game_state <= GAME_PAUSE;
                    pause_select <= 0;
                    pause_bgm <= 1;
                end else if (block_y == ghost_y && (lock_count == 74250000 || move_count >= 15)) begin
                    block_write_buffer <= {curr_addr1, curr_addr2, curr_addr3, curr_addr4};
                    game_state <= PLACE_BLOCK;
                end else if ((fall_down) && (block_y != ghost_y)) begin
                    game_state <= BLOCK_ADDR_WAIT;
                    trigger <= FALL_DOWN;
                    new_block_color <= block_color;
                    new_block_state <= block_state;
                    new_block_x <= block_x;
                    new_block_y <= block_y + 1;
                end else if ((soft_drop_in) && (block_y != ghost_y)) begin
                    soft_drop_points <= soft_drop_points + 1;
                    game_state <= BLOCK_ADDR_WAIT;
                    trigger <= SOFT_DROP;
                    new_block_color <= block_color;
                    new_block_state <= block_state;
                    new_block_x <= block_x;
                    new_block_y <= block_y + 1;
                end else if (hard_drop_in) begin
                    game_state <= BLOCK_READ_WAIT;
                    trigger <= HARD_DROP;
                    read_addr1 <= ghost_addr1;
                    read_addr2 <= ghost_addr2;
                    read_addr3 <= ghost_addr3;
                    read_addr4 <= ghost_addr4;
                    read_wait <= 0;
                end else if (rotate_in && block_color != YELLOW) begin
                    game_state <= BLOCK_ADDR_WAIT;
                    trigger <= ROTATE;
                    new_block_color <= block_color;
                    new_block_state <= block_state + 1;
                    new_block_x <= block_x;
                    new_block_y <= block_y;
                    kicks_tried <= 0;
                    move_count <= (block_y == ghost_y) ? move_count + 1 : move_count;
                end else if (right_in) begin
                    game_state <= BLOCK_ADDR_WAIT;
                    trigger <= MOVE_RIGHT;
                    new_block_color <= block_color;
                    new_block_state <= block_state;
                    new_block_x <= block_x + 1;
                    new_block_y <= block_y;
                    move_count <= (block_y == ghost_y) ? move_count + 1 : move_count;
                end else if (left_in) begin
                    game_state <= BLOCK_ADDR_WAIT;
                    trigger <= MOVE_LEFT;
                    new_block_color <= block_color;
                    new_block_state <= block_state;
                    new_block_x <= block_x - 1;
                    new_block_y <= block_y;
                    move_count <= (block_y == ghost_y) ? move_count + 1 : move_count;
                end else if (hold_in & ~hold_used) begin
                    hold_block_color <= block_color;
                    hold_used <= 1;
                    if (hold_block_color) begin
                        game_state <= BLOCK_ADDR_WAIT;
                        trigger <= HOLD_SWITCH;
                        new_block_color <= hold_block_color;
                        new_block_state <= 0;
                        new_block_x <= BLOCK_X_START;
                        new_block_y <= (hold_block_color == CYAN) ? BLOCK_Y_START + 1 : BLOCK_Y_START;
                        fall_count <= 0;
                    end else begin
                        game_state <= BLOCK_ADDR_WAIT;
                        trigger <= HOLD_SWITCH;
                        new_block_color <= next_block_color;
                        new_block_state <= 0;
                        new_block_x <= BLOCK_X_START;
                        new_block_y <= (next_block_color == CYAN) ? BLOCK_Y_START + 1 : BLOCK_Y_START;
                        block_buffer_addr <= block_buffer_addr + 1;
                        fall_count <= 0;
                    end
                end else game_state <= GAME_PLAY;
            end
            INCREMENT_SCORE: begin
                increment <= 1;
                game_state <= (incrementer_busy) ? INCREMENT_SCORE_WAIT : INCREMENT_SCORE;
            end
            INCREMENT_SCORE_WAIT: begin
                if (!incrementer_busy) begin
                    score_bcd <= bcd_inc;
                    game_state <= GAME_PLAY;
                end else game_state <= INCREMENT_SCORE_WAIT;
            end
            PLACE_BLOCK: begin
                if (block_write_buffer) begin
                    fill_enable <= 1;
                    write_color <= block_color;
                    fill_addr <= block_write_buffer[8:0];
                    block_write_buffer <= {9'b0, block_write_buffer[35:9]};
                    sound_effect <= LOCK_SOUND;
                end else begin
                    fill_enable <= 0;
                    sound_effect <= 0;
                    game_state <= (trigger == HARD_DROP) ? FALLING_SPECKS_ON : BLOCK_FLASH_ON;
                    block_write_buffer <= (trigger == HARD_DROP) ? {speck_addr1, speck_addr2, speck_addr3, speck_addr4} :
                      {curr_addr1, curr_addr2, curr_addr3, curr_addr4};
                end
            end
            FALLING_SPECKS_ON: begin
                if (speck_y < ghost_y) begin
                    if (block_write_buffer) begin
                        speck_enable <= 1;
                        speck <= 1;
                        speck_addr <= block_write_buffer[8:0];
                        block_write_buffer <= {9'b0, block_write_buffer[35:9]};
                    end else begin
                        speck_y <= speck_y + 1;
                        speck_addr1 <= speck_addr1 + MAP_WIDTH;
                        speck_addr2 <= speck_addr2 + MAP_WIDTH;
                        speck_addr3 <= speck_addr3 + MAP_WIDTH;
                        speck_addr4 <= speck_addr4 + MAP_WIDTH;
                        block_write_buffer <= {speck_addr1 + MAP_WIDTH, speck_addr2 + MAP_WIDTH, 
                          speck_addr3 + MAP_WIDTH, speck_addr4 + MAP_WIDTH};
                    end
                end else begin
                    speck_enable <= 0;
                    game_state <= BLOCK_FLASH_ON;
                    block_write_buffer <= {curr_addr1, curr_addr2, curr_addr3, curr_addr4};
                end
            end
            BLOCK_FLASH_ON: begin
                if (block_write_buffer) begin
                    flash_enable <= 1;
                    flash <= 1;
                    flash_addr <= block_write_buffer[8:0];
                    block_write_buffer <= {9'b0, block_write_buffer[35:9]};
                end else begin
                    flash_enable <= 0;
                    game_state <= PLACE_FX_WAIT;
                    wait_count <= 0;
                end
            end
            PLACE_FX_WAIT: begin
                if (wait_count == 14850000) begin
                    game_state <= (trigger == HARD_DROP) ? FALLING_SPECKS_OFF : BLOCK_FLASH_OFF;
                    block_write_buffer <= (trigger == HARD_DROP) ? 0 : {curr_addr1, curr_addr2, curr_addr3, curr_addr4};
                end else wait_count <= wait_count + 1;
            end
            FALLING_SPECKS_OFF: begin
                if (speck_y > block_y) begin
                    if (block_write_buffer) begin
                        speck_enable <= 1;
                        speck <= 0;
                        speck_addr <= block_write_buffer[8:0];
                        block_write_buffer <= {9'b0, block_write_buffer[35:9]};
                    end else begin
                        speck_y <= speck_y - 1;
                        speck_addr1 <= speck_addr1 - MAP_WIDTH;
                        speck_addr2 <= speck_addr2 - MAP_WIDTH;
                        speck_addr3 <= speck_addr3 - MAP_WIDTH;
                        speck_addr4 <= speck_addr4 - MAP_WIDTH;
                        block_write_buffer <= {speck_addr1 - MAP_WIDTH, speck_addr2 - MAP_WIDTH, 
                          speck_addr3 - MAP_WIDTH, speck_addr4 - MAP_WIDTH};
                    end
                end else begin
                    speck_enable <= 0;
                    game_state <= BLOCK_FLASH_OFF;
                    block_write_buffer <= {curr_addr1, curr_addr2, curr_addr3, curr_addr4};
                end
            end
            BLOCK_FLASH_OFF: begin
                if (block_write_buffer) begin
                    flash_enable <= 1;
                    flash <= 0;
                    flash_addr <= block_write_buffer[8:0];
                    block_write_buffer <= {9'b0, block_write_buffer[35:9]};
                end else begin
                    flash_enable <= 0;
                    game_state <= ROW_READ;
                    row_number <= NUM_ROWS;
                    cleared_rows_buffer <= 0;
                    rows_cleared <= 0;
                    old_level <= level;
                end
            end
            ROW_READ: begin
                if (row_number > 0) begin
                    game_state <= ROW_WAIT;
                    read_addr1 <= (ROW_START_X + 0) + row_number * MAP_WIDTH;
                    read_addr2 <= (ROW_START_X + 1) + row_number * MAP_WIDTH;
                    read_addr3 <= (ROW_START_X + 2) + row_number * MAP_WIDTH;
                    read_addr4 <= (ROW_START_X + 3) + row_number * MAP_WIDTH;
                    read_addr5 <= (ROW_START_X + 4) + row_number * MAP_WIDTH;
                    read_addr6 <= (ROW_START_X + 5) + row_number * MAP_WIDTH;
                    read_addr7 <= (ROW_START_X + 6) + row_number * MAP_WIDTH;
                    read_addr8 <= (ROW_START_X + 7) + row_number * MAP_WIDTH;
                    read_addr9 <= (ROW_START_X + 8) + row_number * MAP_WIDTH;
                    read_addr10 <= (ROW_START_X + 9) + row_number * MAP_WIDTH;
                    read_wait <= 0;
                end else begin
                    if (rows_cleared == 4) begin
                        game_state <= ROW_FLASH_ON;
                        flash_count <= 0;
                        temp_rows_buffer <= cleared_rows_buffer;
                        i <= 0;
                    end else if (rows_cleared) begin
                        game_state <= ROW_CLEAR;
                        sound_effect <= CLEAR_SOUND;
                        temp_rows_buffer <= cleared_rows_buffer;
                        i <= 0;
                    end else begin
                        game_state <= UPDATE_SCORE;
                        calc_score <= 1;
                        lines_converted <= 0;
                        level_converted <= 0;
                        score_converted <= 0;
                        convert <= 1;
                    end
                end
            end
            ROW_WAIT: begin
                read_wait <= ~read_wait;
                game_state <= (read_wait) ? ROW_CHECK : ROW_WAIT;
            end
            ROW_CHECK: begin
                if (read_fill1 & read_fill2 & read_fill3 & read_fill4 & read_fill5 
                  & read_fill6 & read_fill7 & read_fill8 & read_fill9 & read_fill10) begin
                    rows_cleared <= rows_cleared + 1;
                    lines <= lines + 1;
                    line_count <= (line_count == 9) ? 0 : line_count + 1;
                    level <= (line_count == 9) ? level + 1 : level;
                    cleared_rows_buffer <= {cleared_rows_buffer[14:0], row_number};
                end
                game_state <= ROW_READ;
                row_number <= row_number - 1;
            end
            ROW_FLASH_ON: begin
                if (temp_rows_buffer[4:0]) begin
                    flash_enable <= 1;
                    flash <= 1;
                    flash_addr <= (ROW_START_X + i) + temp_rows_buffer[4:0] * MAP_WIDTH;
                    i <= (i == ROW_WIDTH - 1) ? 0 : i + 1;
                    temp_rows_buffer <= (i == ROW_WIDTH - 1) ? {5'b0, temp_rows_buffer[19:5]} : temp_rows_buffer;
                end else begin
                    flash_enable <= 0;
                    game_state <= ROW_FLASH_ON_WAIT;
                    wait_count <= 0;
                end
            end
            ROW_FLASH_ON_WAIT: begin
                if (wait_count == 29700000) begin
                    game_state <= ROW_FLASH_OFF;
                    temp_rows_buffer <= cleared_rows_buffer;
                    i <= 0;
                end else wait_count <= wait_count + 1;
            end
            ROW_FLASH_OFF: begin
                if (temp_rows_buffer[4:0]) begin
                    flash_enable <= 1;
                    flash <= 0;
                    flash_addr <= (ROW_START_X + i) + temp_rows_buffer[4:0] * MAP_WIDTH;
                    i <= (i == ROW_WIDTH - 1) ? 0 : i + 1;
                    temp_rows_buffer <= (i == ROW_WIDTH - 1) ? {5'b0, temp_rows_buffer[19:5]} : temp_rows_buffer;
                end else begin
                    flash_enable <= 0;
                    game_state <= ROW_FLASH_OFF_WAIT;
                    wait_count <= 0;
                end
            end
            ROW_FLASH_OFF_WAIT: begin
                if (wait_count == 29700000) begin
                    flash_count <= flash_count + 1;
                    game_state <= (flash_count) ? ROW_CLEAR : ROW_FLASH_ON;
                    temp_rows_buffer <= cleared_rows_buffer;
                    i <= 0;
                    sound_effect <= (flash_count) ? CLEAR_SOUND : 0;
                end else wait_count <= wait_count + 1;
            end
            ROW_CLEAR: begin
                sound_effect <= 0;
                if (i < ROW_WIDTH) begin
                    if (temp_rows_buffer[4:0]) begin
                        write_enable <= 1;
                        write_color <= 0;
                        square_write_addr <= (ROW_START_X + i) + temp_rows_buffer[4:0] * MAP_WIDTH;
                        temp_rows_buffer <= {5'b0, temp_rows_buffer[19:5]};
                    end else begin
                        write_enable <= 0;
                        game_state <= ROW_CLEAR_WAIT;
                        wait_count <= 0;
                    end
                end else begin
                    game_state <= ROW_SHIFT_READ;
                    i <= 0;
                    j <= 0;
                end    
            end
            ROW_CLEAR_WAIT: begin
                if (wait_count == 7425000) begin
                    game_state <= ROW_CLEAR;
                    temp_rows_buffer <= cleared_rows_buffer;
                    i <= i + 1;
                end else wait_count <= wait_count + 1;
            end
            ROW_SHIFT_READ: begin
                if (cleared_rows_buffer) begin
                    if (j < cleared_rows_buffer[4:0]) begin
                        square_read_addr <= (ROW_START_X + i) + ((cleared_rows_buffer[4:0] - j) - 1) * MAP_WIDTH;
                        game_state <= ROW_SHIFT_WAIT;
                    end else begin
                        cleared_rows_buffer <= {5'b0, cleared_rows_buffer[19:5]};
                        i <= 0;
                        j <= 0;
                    end
                end else begin
                    write_enable <= 0;
                    fill_enable <= 0;
                    game_state <= UPDATE_SCORE;
                    calc_score <= 1;
                    lines_converted <= 0;
                    level_converted <= 0;
                    score_converted <= 0;
                    convert <= 1;
                end
            end
            ROW_SHIFT_WAIT: begin
                game_state <= ROW_SHIFT_WRITE;
            end
            ROW_SHIFT_WRITE: begin
                write_enable <= 1;
                fill_enable <= 1;
                write_color <= read_color;
                square_write_addr <= square_read_addr + MAP_WIDTH;
                game_state <= ROW_SHIFT_READ;
                i <= (i == ROW_WIDTH - 1) ? 0 : i + 1;
                j <= (i == ROW_WIDTH - 1) ? j + 1 : j;
            end
            UPDATE_SCORE: begin
                calc_score <= 0;
                if (!lines_converted)
                    game_state <= (converter_busy) ? SCORE_WAIT : UPDATE_SCORE;
                else if (!level_converted)
                    game_state <= (converter_busy) ? SCORE_WAIT : UPDATE_SCORE;    
                else if (!score_converted)
                    game_state <= (converter_busy) ? SCORE_WAIT : UPDATE_SCORE;
                else begin
                    game_state <= BLOCK_ADDR_WAIT;
                    trigger <= NEW_BLOCK;
                    new_block_color <= next_block_color;
                    new_block_state <= 0;
                    new_block_x <= BLOCK_X_START;
                    new_block_y <= (next_block_color == CYAN) ? BLOCK_Y_START + 1 : BLOCK_Y_START;;
                    block_buffer_addr <= block_buffer_addr + 1;
                    fall_count <= 0;
                    lock_count <= 0;
                    move_count <= 0;
                    soft_drop_points <= 0;
                    hold_used <= 0;
                end
            end
            SCORE_WAIT: begin
                if (!lines_converted) begin
                    if (!converter_busy) begin
                        lines_bcd <= bcd_out;
                        lines_converted <= 1;
                        game_state <= UPDATE_SCORE;
                    end else game_state <= SCORE_WAIT;
                end else if (!level_converted) begin
                    if (!converter_busy) begin
                        level_bcd <= bcd_out;
                        level_converted <= 1;
                        game_state <= UPDATE_SCORE;
                    end else game_state <= SCORE_WAIT;
                end else if (!score_converted) begin
                    if (!converter_busy) begin
                        score_bcd <= bcd_out;
                        score_converted <= 1;
                        convert <= 0;
                        game_state <= UPDATE_SCORE;
                    end else game_state <= SCORE_WAIT;
                end
            end
            GAME_PAUSE: begin
                pause_select <= (down_in) ? 1 : (up_in) ? 0 : pause_select;
                if (select_in) begin
                    game_state <= (pause_select) ? START_SCREEN : GAME_PLAY;
                    pause_bgm <= (pause_select) ? 1 : 0;
                end
            end                    
            GAME_OVER: begin
                game_over_select <= (down_in) ? 1 : (up_in) ? 0 : game_over_select;
                if (select_in) begin
                    game_state <= (game_over_select) ? START_SCREEN : RESET;
                    pause_bgm <= (game_over_select) ? 1 : 0;
                end
            end
            default: game_state <= START_SCREEN;
        endcase
    end
    
endmodule