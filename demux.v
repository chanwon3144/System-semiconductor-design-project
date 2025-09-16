`timescale 1ns / 1ps


module demux(
    input btnL, btnR, btnU, btnD,
    input mode_sel, // sw[1] → 0: stopwatch, 1: watch
    input display_sel, // sw[0] → 시간단위 선택용
    
    // stopwatch용 출력
    output sw_btnL, sw_btnR,

    // watch용 출력
    output watch_btnL, watch_btnR,
    output watch_btnU, watch_btnD
    );


    // stopwatch
    assign sw_btnL  = (mode_sel == 1'b0) ? btnL : 1'b0;
    assign sw_btnR  = (mode_sel == 1'b0) ? btnR : 1'b0;

    // watch
    assign watch_btnL  = (mode_sel == 1'b1) ? btnL : 1'b0;
    assign watch_btnR  = (mode_sel == 1'b1) ? btnR : 1'b0;
    assign watch_btnU  = (mode_sel == 1'b1) ? btnU : 1'b0;
    assign watch_btnD  = (mode_sel == 1'b1) ? btnD : 1'b0;

    
endmodule
