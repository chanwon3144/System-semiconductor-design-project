`timescale 1ns / 1ps

module watch(
    input clk,
    input rst,
    input btnL, btnR, btnU, btnD,
    input  [1:0] switch,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour,
    output [2:0] led
    );

    wire [1:0] sel_pos;
    wire inc, dec;

    // CU: 버튼 제어 (위치 선택 + inc/dec)
    watch_cu U_CU (
        .clk(clk),
        .rst(rst),
        .i_left(btnL),
        .i_right(btnR),
        .i_up(btnU),
        .i_down(btnD),
        .sel_pos(sel_pos),
        .o_inc(inc),
        .o_dec(dec)
    );

    // DP: 시간 흐름 + 선택된 위치 증감
    watch_dp U_DP (
        .clk(clk),
        .rst(rst),
        .sel_pos(sel_pos),
        .inc(inc),
        .dec(dec),
        .switch(switch),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .led(led)
);
endmodule

