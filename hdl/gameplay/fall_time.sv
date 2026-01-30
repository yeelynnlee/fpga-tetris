`timescale 1ns / 1ps

module fall_time( input clk_in,
                  input [4:0] level,
                  output logic [27:0] fall_time

    );
    
    //fall time = ((0.8 - ((level - 1) * 0.007)) ** (level - 1)) * clock frequency
    parameter LEVEL_1_FALL_TIME = 148500000;
    parameter LEVEL_2_FALL_TIME = 117760500;
    parameter LEVEL_3_FALL_TIME = 91742706;
    parameter LEVEL_4_FALL_TIME = 70200277;
    parameter LEVEL_5_FALL_TIME = 52746744;
    parameter LEVEL_6_FALL_TIME = 38907527;
    parameter LEVEL_7_FALL_TIME = 28167071;
    parameter LEVEL_8_FALL_TIME = 20008108;
    parameter LEVEL_9_FALL_TIME = 13941514;
    parameter LEVEL_10_FALL_TIME = 9526510;
    parameter LEVEL_11_FALL_TIME = 6381974;
    parameter LEVEL_12_FALL_TIME = 4190325;
    parameter LEVEL_13_FALL_TIME = 2695769;
    parameter LEVEL_14_FALL_TIME = 1698742;
    parameter LEVEL_15_FALL_TIME = 1048205;
    parameter LEVEL_16_FALL_TIME = 633138;
    parameter LEVEL_17_FALL_TIME = 374232;
    parameter LEVEL_18_FALL_TIME = 216385;
    parameter LEVEL_19_FALL_TIME = 122350;
    
    always_ff @ (posedge clk_in) begin
        case(level)
            1: fall_time <= LEVEL_1_FALL_TIME;
            2: fall_time <= LEVEL_2_FALL_TIME;
            3: fall_time <= LEVEL_3_FALL_TIME;
            4: fall_time <= LEVEL_4_FALL_TIME;
            5: fall_time <= LEVEL_5_FALL_TIME;
            6: fall_time <= LEVEL_6_FALL_TIME;
            7: fall_time <= LEVEL_7_FALL_TIME;
            8: fall_time <= LEVEL_8_FALL_TIME;
            9: fall_time <= LEVEL_9_FALL_TIME;
            10: fall_time <= LEVEL_10_FALL_TIME;
            11: fall_time <= LEVEL_11_FALL_TIME;
            12: fall_time <= LEVEL_12_FALL_TIME;
            13: fall_time <= LEVEL_13_FALL_TIME;
            14: fall_time <= LEVEL_14_FALL_TIME;
            15: fall_time <= LEVEL_15_FALL_TIME;
            16: fall_time <= LEVEL_16_FALL_TIME;
            17: fall_time <= LEVEL_17_FALL_TIME;
            18: fall_time <= LEVEL_18_FALL_TIME;
            19: fall_time <= LEVEL_19_FALL_TIME;
            default: fall_time <= LEVEL_19_FALL_TIME;
        endcase
    end
    
endmodule
