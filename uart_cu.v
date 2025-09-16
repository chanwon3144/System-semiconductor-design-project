`timescale 1ns / 1ps

module uart_cu (
    input       clk,
    input       rst,
    input       rx_done,
    input [7:0] rx_data,
    output reg [3:0] btn_uart   // [0]:U, [1]:L/C, [2]:R/G/S, [3]:D
);

    // FSM 상태 정의 (stopwatch용)
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;

    reg [1:0] c_state, n_state;
    reg [3:0] btn_uart_reg;
    reg [3:0] btn_uart_hold;
    reg [16:0] hold_cnt;
    reg hold_en;

    // FSM 전이 조건: stopwatch 모드에서 G/S/C 입력일 때만 전이
    wire is_fsm_cmd = (rx_data == "G") || (rx_data == "S") || (rx_data == "C");
    wire w_rst = rst || (rx_data == 8'h1B);

    // FSM 상태 저장
    always @(posedge clk or posedge w_rst) begin
        if (w_rst)
            c_state <= STOP;
        else if (rx_done && is_fsm_cmd)
            c_state <= n_state;
    end

    // FSM 전이 정의
    always @(*) begin
        n_state = c_state;
        if (rx_data == "C") n_state = CLEAR;
        else begin
            case (c_state)
                STOP:  if (rx_data == "G") n_state = RUN;
                RUN:   if (rx_data == "S") n_state = STOP;
                CLEAR: n_state = STOP;
            endcase
        end
    end

    // watch 모드 버튼 매핑
    wire [3:0] w_btn_code =
        (rx_data == "U") ? 4'b0001 :
        (rx_data == "D") ? 4'b1000 :
        (rx_data == "R") ? 4'b0100 :
        (rx_data == "L") ? 4'b0010 :
        4'b0000;

    // stopwatch 버튼 FSM 기반 처리
    always @(posedge clk or posedge w_rst) begin
        if (w_rst)
            btn_uart_reg <= 4'b0000;
        else if (rx_done) begin
            if (rx_data == "G" || rx_data == "S")
                btn_uart_reg <= 4'b0100; // btnR
            else if (rx_data == "C")
                btn_uart_reg <= 4'b0010; // btnL
            else
                btn_uart_reg <= w_btn_code; // watch 모드 버튼
        end else
            btn_uart_reg <= 4'b0000;
    end

    // 1ms 유지
    always @(posedge clk or posedge w_rst) begin
        if (w_rst) begin
            btn_uart_hold <= 0;
            hold_cnt <= 0;
            hold_en <= 0;
        end else begin
            if (btn_uart_reg != 0) begin
                btn_uart_hold <= btn_uart_reg;
                hold_cnt <= 0;
                hold_en <= 1;
            end else if (hold_en) begin
                if (hold_cnt == 100_000 - 1) begin
                    btn_uart_hold <= 0;
                    hold_en <= 0;
                end else begin
                    hold_cnt <= hold_cnt + 1;
                end
            end
        end
    end

    // 출력
    always @(posedge clk or posedge w_rst) begin
        if (w_rst)
            btn_uart <= 0;
        else
            btn_uart <= btn_uart_hold;
    end

endmodule


