
`timescale 1ns / 1ps

module baudrate (
    input  clk,
    input  rst,
    output baud_tick
);

    // clk 100Mhz, 100메가에 baudrate 나누기
    parameter BAUD = 9600; // 초당 9600바트
    parameter BAUD_COUNT = 100_000_000 / (BAUD * 8); // 원래 있던 tick 하나를 8개로
    reg [$clog2(BAUD_COUNT) - 1:0] count_reg, count_next;
    reg baud_tick_reg, baud_tick_next;
    reg [16:0] baud_count;
    
    assign baud_tick = baud_tick_reg;

    // sl, 상태저장 플리플롭 생성
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            baud_tick_reg <= 0;
        end else begin
            count_reg <= count_next; // 비트 수 만큼 플리플롭 생성
            baud_tick_reg <= baud_tick_next;
        end
    end

    // cl
    always @(*) begin
        count_next = count_reg;
        baud_tick_next = 0; // baud_tick_reg로 초기화 해도 된다. tick 자체를 생성만 하기 때문에 가능. 둘 다 상관 없다 
        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0; // 비교는 현재랑 하고 next는 0으로
            baud_tick_next = 1'b1;
        end else begin
            count_next = count_reg + 1;
            baud_tick_next = 1'b0;
        end
    end


endmodule

