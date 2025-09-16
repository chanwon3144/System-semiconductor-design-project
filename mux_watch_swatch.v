`timescale 1ns / 1ps



module mux_watch_swatch_sr04_hdt11 (
    input             sel,          // sw[1]
    input      [23:0] swatch_data,  // stopwatch에서 온 데이터
    input      [23:0] watch_data,   // watch에서 온 데이터
    output reg [23:0] out_data      // MUX 출력
);

    always @(*) begin
        case (sel)
            1'b0: out_data = swatch_data;  // stopwatch
            1'b1: out_data = watch_data;  // watch
            default: out_data = 24'h000000;
        endcase
    end
endmodule



