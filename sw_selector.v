`timescale 1ns / 1ps

module sw_selector (
    input        clk,
    input        rst,
    input        rx_done,
    input  [7:0] rx_data,
    input  [1:0] sw_phy,       // 물리 스위치 입력
    output [1:0] sw_final      // 실제 사용할 스위치 (unit, mode)
);

    reg [1:0] sw_uart;         // UART로 토글된 값
    reg       sw_uart_valid;  // UART 우선권 플래그
    reg [1:0] prev_sw_phy;    // 물리 스위치 변경 감지용

    // UART 토글 + 물리 우선권 회수 → 하나의 always 블록으로 통합
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sw_uart        <= 2'b00;
            sw_uart_valid  <= 1'b0;
            prev_sw_phy    <= 2'b00;
        end else begin
            // UART 입력 → sw_uart 토글 및 우선권 부여
            if (rx_done) begin
                case (rx_data)
                    "n": begin
                        sw_uart[1] <= ~sw_uart[1];  // mode toggle
                        sw_uart_valid <= 1'b1;
                    end
                    "m": begin
                        sw_uart[0] <= ~sw_uart[0];  // unit toggle
                        sw_uart_valid <= 1'b1;
                    end
                endcase
            end

            // 물리 스위치가 바뀌면 UART 우선권 해제
            if (sw_phy != prev_sw_phy) begin
                sw_uart_valid <= 1'b0;
                sw_uart <= sw_phy; // 물리 스위치 값으로 업데이트
            end
            prev_sw_phy <= sw_phy;
        end
    end

    // 우선순위 기반 최종 스위치 선택
    assign sw_final = sw_uart_valid ? sw_uart : sw_phy;

endmodule

