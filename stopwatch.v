`timescale 1ns / 1ps

module stopwatch (
    input        clk,
    input        rst,
    input        btnL_Clear,
    input        btnR_RunStop,
    input        switch, // sw[0]만 입력됨 (0: msec/sec, 1: min/hour)
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire w_clear, w_runstop;



    stopwatch_cu U_Stopwatch_CU (
        .clk(clk),
        .rst(rst),
        .i_clear(btnL_Clear),
        .i_runstop(btnR_RunStop),
        .o_clear(w_clear),
        .o_runstop(w_runstop)
    );

    stopwatch_dp U_Stopwatch_DP (
        .clk(clk),
        .rst(rst),
        .run_stop(w_runstop),
        .clear(w_clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );


endmodule
