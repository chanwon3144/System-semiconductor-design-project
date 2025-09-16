`timescale 1ns / 1ps


module uart_tx (
    input clk,
    input rst,
    input baud_tick,
    input start,
    input [7:0] din,
    output o_tx_done,
    output o_tx_busy,
    output o_tx
);

    // state는 바꾸지 못하게 하려고 localparam을 주로 사용함
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3, WAIT = 4;

    reg [2:0] c_state, n_state; // 현재 상태, 다음 상태
    reg tx_reg, tx_next; // 클럭이 업데이트 되는 시점에 tx_reg을 내보냄 ** 주석 수정 필요
    reg [2:0] data_cnt_reg, data_cnt_next; // 0부터 7까지 새야하니까 3bit 필요, 안에서 변화가 있으면 next로 들어가야 한다.
    reg [3:0] b_cnt_reg, b_cnt_next; // baud count, tick 8배속을 위한 것
    reg tx_done_reg, tx_done_next;
    reg tx_busy_reg, tx_busy_next;

    assign o_tx = tx_reg;
    assign o_tx_done = tx_done_reg;
    assign o_tx_busy = tx_busy_reg;
    // assign o_tx_done = ((c_state == STOP) & (b_cnt_reg == 7))? 1'b1: 1'b0; // 비교는 항상 reg와와

    // state register (상태 저장하는 플리플롭 생성)
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 0;
            tx_reg <= 1'b1; // 출력 초기를 High로, rst걸리면 1을 유지하고 있을 것것
            data_cnt_reg <= 0; // data bit 전송 반복 구조를 위해 존재
            b_cnt_reg <= 0; // baud tick을 0부터 7까지 count
            tx_done_reg <= 0;
            tx_busy_reg <= 0;
        end else begin
            c_state <= n_state;
            tx_reg <= tx_next;
            data_cnt_reg <= data_cnt_next;
            b_cnt_reg <= b_cnt_next;
            tx_done_reg <= tx_done_next;
            tx_busy_reg <= tx_busy_next;
        end
    end

    // next state CL (어떤 조건에서 바뀌는지 설정) 조합논리에는 *이 무난
    always @(*) begin
        n_state = c_state;
        tx_next = tx_reg;
        data_cnt_next = data_cnt_reg;
        b_cnt_next = b_cnt_reg;
        tx_done_next = 0;
        tx_busy_next = tx_busy_reg;
        case (c_state)
            IDLE: begin
                b_cnt_next = 0;
                data_cnt_next = 0;
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                tx_busy_next = 1'b0;
                if (start == 1'b1) begin // start == 1'b1 & baud_tick ==1 로 한 번에 넣으면 안된다.(동시 처리 구조임 이건. 나는 순서가 있음)
                    n_state = START; // tick을 보지 않고 START로 넘겨버림, 그래서 START에서 1부터 8까지 셈
                    tx_busy_next = 1'b1;
                end
            end 
            START: begin
                if (baud_tick == 1'b1) begin // 이미 state는 START에 가 있는 상태에서 tick을 기다림
                    tx_next = 1'b0; // START 조건이 tx=0일 때 나가는 거임
                    if (b_cnt_reg == 8) begin // 8tick되면 state를 넘김
                        n_state = DATA;
                        data_cnt_next = 0; // 초기화 왜 해줘? state이 DATA로 넘어가기 때문에 그 전에 초기화 해줌
                        b_cnt_next = 0; // 초기화 왜 해줘? buad tick count도 초기화
                    end else begin
                        b_cnt_next = b_cnt_reg + 1; // 시작하자마자 0이 아니라 1로 들어가서 8로 바꿔준 거임임
                    end
                end
            end
            DATA: begin
                tx_next = din[data_cnt_reg];
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin // else에서 시작하자마 0이 아니라 1로 들어가서 7에서 8로 바꿔줌, 8이 들어오면 다음으로 넘어감
                        if (data_cnt_reg == 3'b111) begin 
                            n_state = STOP;
                        end
                        b_cnt_next = 0; // 8번 돌면 초기화
                        data_cnt_next = data_cnt_reg + 1;  
                    end else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin
                        n_state = IDLE;
                        tx_done_next = 1'b1;
                        tx_busy_next = 1'b0;
                    end else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end
                end
            end
    
        endcase
    end
endmodule