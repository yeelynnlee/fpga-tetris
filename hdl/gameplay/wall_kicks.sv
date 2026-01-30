`timescale 1ns / 1ps

module wall_kicks( input [2:0] block_color,
                   input [1:0] block_state,
                   input [3:0] block_x,
                   input [4:0] block_y,
                   input [2:0] kicks_tried,
                   output logic [3:0] kick_block_x,
                   output logic [4:0] kick_block_y

    );
    
    parameter RED = 3'b001;
    parameter ORANGE = 3'b010;
    parameter YELLOW = 3'b011;
    parameter GREEN = 3'b100;
    parameter BLUE = 3'b101;
    parameter PURPLE = 3'b110;
    parameter CYAN = 3'b111;
    
    always_comb begin
        if (block_color == RED || block_color == ORANGE || block_color == GREEN ||
          block_color == BLUE || block_color == PURPLE) begin
            case(block_state)
                0: begin
                    case(kicks_tried)
                        0: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y;
                        end
                        1: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y + 1;
                        end
                        2: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y - 2;
                        end
                        3: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y - 2;
                        end
                        default: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y;
                        end
                    endcase
                end
                1: begin
                    case(kicks_tried)
                        0: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y;
                        end
                        1: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y - 1;
                        end
                        2: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y + 2;
                        end
                        3: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y + 2;
                        end
                        default: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y;
                        end
                    endcase
                end
                2: begin
                    case(kicks_tried)
                        0: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y;
                        end
                        1: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y + 1;
                        end
                        2: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y - 2;
                        end
                        3: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y - 2;
                        end
                        default: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y;
                        end
                    endcase
                end
                3: begin
                    case(kicks_tried)
                        0: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y;
                        end
                        1: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y - 1;
                        end
                        2: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y + 2;
                        end
                        3: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y + 2;
                        end
                        default: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y;
                        end
                    endcase
                end
            endcase
        end else if (block_color == CYAN) begin
            case(block_state)
                0: begin
                    case(kicks_tried)
                        0: begin
                            kick_block_x = block_x - 2;
                            kick_block_y = block_y;
                        end
                        1: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y;
                        end
                        2: begin
                            kick_block_x = block_x - 2;
                            kick_block_y = block_y - 1;
                        end
                        3: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y + 2;
                        end
                        default: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y;
                        end
                    endcase
                end
                1: begin
                    case(kicks_tried)
                        0: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y;
                        end
                        1: begin
                            kick_block_x = block_x + 2;
                            kick_block_y = block_y;
                        end
                        2: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y + 2;
                        end
                        3: begin
                            kick_block_x = block_x + 2;
                            kick_block_y = block_y - 1;
                        end
                        default: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y;
                        end
                    endcase
                end
                2: begin
                    case(kicks_tried)
                        0: begin
                            kick_block_x = block_x + 2;
                            kick_block_y = block_y;
                        end
                        1: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y;
                        end
                        2: begin
                            kick_block_x = block_x + 2;
                            kick_block_y = block_y + 1;
                        end
                        3: begin
                            kick_block_x = block_x - 1;
                            kick_block_y = block_y - 2;
                        end
                        default: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y;
                        end
                    endcase
                end
                3: begin
                    case(kicks_tried)
                        0: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y;
                        end
                        1: begin
                            kick_block_x = block_x - 2;
                            kick_block_y = block_y;
                        end
                        2: begin
                            kick_block_x = block_x + 1;
                            kick_block_y = block_y - 2;
                        end
                        3: begin
                            kick_block_x = block_x - 2;
                            kick_block_y = block_y + 1;
                        end
                        default: begin
                            kick_block_x = block_x;
                            kick_block_y = block_y;
                        end
                    endcase
                end
            endcase
        end else begin
            kick_block_x = block_x;
            kick_block_y = block_y;
        end   
    end
    
endmodule
