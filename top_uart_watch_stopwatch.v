
`timescale 1ns / 1ps

module top_uart_watch_stopwatch (
    input clk,
    input rst,
    input [1:0] sw,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    input rx,
    output tx,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [3:0] led,
    output [2:0] led_pos
);

    wire [7:0] rx_data;
    wire       rx_done;
    wire       tx_done;
    wire [7:0] tx_din;
    wire       tx_start;

    // UART Controller 연결
    uart_controller U_UART (
        .clk(clk),
        .rst(rst),
        .tx_din(tx_din),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .tx_done(tx_done),
        .tx(tx)
    );

    // UART CU 연동
    wire [3:0] btn_uart;
    //wire [1:0] sw_uart;

    uart_cu U_CU (
        .clk(clk),
        .rst(rst),
        .rx_done(rx_done),
        .rx_data(rx_data),
        .btn_uart(btn_uart)
    );

    wire [1:0] sw_final;

    sw_selector U_SW_SEL (
        .clk     (clk),
        .rst     (rst),
        .rx_done (rx_done),
        .rx_data (rx_data),
        .sw_phy  (sw),       // 물리 스위치
        .sw_final(sw_final)  // 최종 스위치
    );

    // 분해
    wire time_unit = sw_final[0];  // 0=sec/ms, 1=hour/min
    wire watch_mode = sw_final[1];  // 0=stopwatch, 1=watch

    // UART 버튼 입력 통합 (pulse)
    wire btnU_all = btnU | btn_uart[0];  // "U"
    wire btnL_all = btnL | btn_uart[1];  // "C"/"L"
    wire btnR_all = btnR | btn_uart[2];  // "G"/"S"/"R"
    wire btnD_all = btnD | btn_uart[3];  // "D"

    // 상위 watch+stopwatch 통합 모듈
    top_watch U_TOP_WATCH (
        .clk(clk),
        .rst(rst),
        .btnU(btnU_all),
        .btnD(btnD_all),
        .btnL(btnL_all),
        .btnR(btnR_all),
        .time_unit(time_unit),
        .watch_mode(watch_mode),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com),
        .led(led),
        .led_pos(led_pos)
    );
endmodule




