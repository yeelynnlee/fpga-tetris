`timescale 1ns / 1ps

module block_addresses( input clk_in,
                        input [2:0] block_color,
                        input [1:0] block_state,
                        input [3:0] block_x,
                        input [4:0] block_y,
                        output logic [8:0] addr1, addr2, addr3, addr4
    );
    
    parameter RED = 3'b001;
    parameter ORANGE = 3'b010;
    parameter YELLOW = 3'b011;
    parameter GREEN = 3'b100;
    parameter BLUE = 3'b101;
    parameter PURPLE = 3'b110;
    parameter CYAN = 3'b111;
    
    parameter MAP_WIDTH = 14;
   
    //0: (block_x) + (block_y) * MAP_WIDTH
    //1: (block_x + 1) + (block_y) * MAP_WIDTH
    //2: (block_x + 2) + (block_y) * MAP_WIDTH
    //3: (block_x + 3) + (block_y) * MAP_WIDTH
    //4: (block_x) + (block_y + 1) * MAP_WIDTH
    //5: (block_x + 1) + (block_y + 1) * MAP_WIDTH
    //6: (block_x + 2) + (block_y + 1) * MAP_WIDTH
    //7: (block_x + 3) + (block_y + 1) * MAP_WIDTH
    //8: (block_x) + (block_y + 2) * MAP_WIDTH
    //9: (block_x + 1) + (block_y + 2) * MAP_WIDTH
    //10: (block_x + 2) + (block_y + 2) * MAP_WIDTH
    //11: (block_x + 3) + (block_y + 2) * MAP_WIDTH
    //12: (block_x) + (block_y + 3) * MAP_WIDTH
    //13: (block_x + 1) + (block_y + 3) * MAP_WIDTH
    //14: (block_x + 2) + (block_y + 3) * MAP_WIDTH
    //15: (block_x + 3) + (block_y + 3) * MAP_WIDTH 
    
    always_ff @(posedge clk_in) begin
        case(block_color)
            RED: begin
                case(block_state)
                    0: begin
                        addr1 <= (block_x) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                    end
                    1: begin
                        addr1 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                    2: begin
                        addr1 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 3) * MAP_WIDTH;
                    end
                    3: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x) + (block_y + 3) * MAP_WIDTH;
                    end
                endcase
            end
            ORANGE: begin
                case(block_state)
                    0: begin
                        addr1 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                    end
                    1: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 3) * MAP_WIDTH;
                    end
                    2: begin
                        addr1 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x) + (block_y + 3) * MAP_WIDTH;
                    end
                    3: begin
                        addr1 <= (block_x) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                endcase
            end
            YELLOW: begin
                case(block_state)
                    0: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                    end
                    1: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                    end
                    2: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                    end
                    3: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                    end
                endcase
            end
            GREEN: begin
                case(block_state)
                    0: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                    end
                    1: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 3) * MAP_WIDTH;
                    end
                    2: begin
                        addr1 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr2 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x) + (block_y + 3) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                    3: begin
                        addr1 <= (block_x) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                endcase
            end
            BLUE: begin
                case(block_state)
                    0: begin
                        addr1 <= (block_x) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                    end
                    1: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                    2: begin
                        addr1 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 3) * MAP_WIDTH;
                    end
                    3: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x) + (block_y + 3) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                endcase
            end 
            PURPLE: begin
                case(block_state)
                    0: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                    end
                    1: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                    2: begin
                        addr1 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                    3: begin
                        addr1 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                endcase
            end
            CYAN: begin
                case(block_state)
                    0: begin
                        addr1 <= (block_x) + (block_y + 1) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr4 <= (block_x + 3) + (block_y + 1) * MAP_WIDTH;
                    end
                    1: begin
                        addr1 <= (block_x + 2) + (block_y) * MAP_WIDTH;
                        addr2 <= (block_x + 2) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 2) + (block_y + 3) * MAP_WIDTH;
                    end
                    2: begin
                        addr1 <= (block_x) + (block_y + 2) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr3 <= (block_x + 2) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 3) + (block_y + 2) * MAP_WIDTH;
                    end
                    3: begin
                        addr1 <= (block_x + 1) + (block_y) * MAP_WIDTH;
                        addr2 <= (block_x + 1) + (block_y + 1) * MAP_WIDTH;
                        addr3 <= (block_x + 1) + (block_y + 2) * MAP_WIDTH;
                        addr4 <= (block_x + 1) + (block_y + 3) * MAP_WIDTH;
                    end
                endcase
            end
        endcase
    end 

endmodule
