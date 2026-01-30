`timescale 1ns / 1ps

module synchronize #(parameter DATA_WIDTH = 1)
                    (input clk_in, 
                     input [DATA_WIDTH - 1: 0] in,
                     output logic [DATA_WIDTH - 1:0] out
    
    );

    logic [DATA_WIDTH - 1:0] sync;

    always_ff @(posedge clk_in) begin
        {out, sync} <= {sync[DATA_WIDTH - 1:0], in};
    end
  
endmodule
