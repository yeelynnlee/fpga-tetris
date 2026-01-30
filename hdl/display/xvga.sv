`timescale 1ns / 1ps

module xvga(    input vclock_in,
                output logic [11:0] hcount_out,    // pixel number on current line
                output logic [10:0] vcount_out,    // line number
                output logic vsync_out, hsync_out,
                output logic blank_out);

    parameter DISPLAY_WIDTH  = 1920;      // display width
    parameter DISPLAY_HEIGHT = 1080;      // number of lines

    parameter  H_FP = 88;                 // horizontal front porch
    parameter  H_SYNC_PULSE = 44;         // horizontal sync
    parameter  H_BP = 148;                // horizontal back porch

    parameter  V_FP = 4;                  // vertical front porch
    parameter  V_SYNC_PULSE = 5;          // vertical sync 
    parameter  V_BP = 36;                 // vertical back porch

    // horizontal: 2200 pixels total
    // display 1920 pixels per line
    logic hblank, hsyncon,hsyncoff,hreset,hblankon;
    assign hblankon = (hcount_out == (DISPLAY_WIDTH -1));    
    assign hsyncon = (hcount_out == (DISPLAY_WIDTH + H_FP - 1));
    assign hsyncoff = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE - 1));
    assign hreset = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE + H_BP - 1));

    // vertical: 1125 lines total
    // display 1080 lines
    logic vblank, vsyncon,vsyncoff,vreset,vblankon;
    assign vblankon = hreset & (vcount_out == (DISPLAY_HEIGHT - 1));
    assign vsyncon = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP - 1));
    assign vsyncoff = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE - 1));
    assign vreset = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE + V_BP - 1));

    // sync and blanking
    logic next_hblank, next_vblank;
    assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
    assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
    
    always_ff @(posedge vclock_in) begin
       hcount_out <= hreset ? 0 : hcount_out + 1;
       hblank <= next_hblank;
       hsync_out <= hsyncon ? 1 : hsyncoff ? 0 : hsync_out;

       vcount_out <= hreset ? (vreset ? 0 : vcount_out + 1) : vcount_out;
       vblank <= next_vblank;
       vsync_out <= vsyncon ? 1 : vsyncoff ? 0 : vsync_out;

       blank_out <= next_vblank | next_hblank;
    end
   
endmodule