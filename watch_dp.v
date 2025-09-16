`timescale 1ns / 1ps

module watch_dp (
    input clk,
    input rst,
    input [1:0] sel_pos,  // 0: sec, 1: min, 2: hour
    input inc,
    input dec,
    input [1:0] switch,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour,
    output reg [3:0] led
);

    wire w_tick_100hz;
    wire tick_msec_over, tick_sec_over, tick_min_over;

    always @(*) begin
        led = 3'b000;
        case (sel_pos)
            2'b00: led = 3'b001;  // 초
            2'b01: led = 3'b010;  // 분
            2'b10: led = 3'b100;  // 시
        endcase
    end

    tick_gen_100hz U_Tick_100hz (
        .clk(clk),
        .rst(rst),
        .o_tick_100(w_tick_100hz)
    );

    time_counter_watch #(
        .BIT_WIDTH (7),
        .TICK_COUNT(100),
        .INIT_VALUE(0)
    ) U_MSEC (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .i_inc(),
        .i_dec(),
        .o_time(msec),
        .o_tick(tick_msec_over)
    );

    time_counter_watch #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60),
        .INIT_VALUE(0)
    ) U_SEC (
        .clk(clk),
        .rst(rst),
        .i_tick(tick_msec_over),
        .i_inc((switch[1] && sel_pos == 2'd0) ? inc : 1'b0),
        .i_dec((switch[1] && sel_pos == 2'd0) ? dec : 1'b0),
        .o_time(sec),
        .o_tick(tick_sec_over)
    );

    time_counter_watch #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60),
        .INIT_VALUE(0)
    ) U_MIN (
        .clk(clk),
        .rst(rst),
        .i_tick(tick_sec_over),
        .i_inc((switch[1] && sel_pos == 2'd1) ? inc : 1'b0),
        .i_dec((switch[1] && sel_pos == 2'd1) ? dec : 1'b0),
        .o_time(min),
        .o_tick(tick_min_over)
    );

    time_counter_watch #(
        .BIT_WIDTH (5),
        .TICK_COUNT(24),
        .INIT_VALUE(12)
    ) U_HOUR (
        .clk(clk),
        .rst(rst),
        .i_tick(tick_min_over),
        .i_inc((switch[1] && sel_pos == 2'd2) ? inc : 1'b0),
        .i_dec((switch[1] && sel_pos == 2'd2) ? dec : 1'b0),
        .o_time(hour),
        .o_tick()
    );

endmodule

module time_counter_watch #(
    parameter BIT_WIDTH = 6,
    TICK_COUNT = 60,
    INIT_VALUE = 0
) (
    input                      clk,
    input                      rst,
    input                      i_tick,
    input                      i_inc,
    input                      i_dec,
    output reg [BIT_WIDTH-1:0] o_time,
    output reg                 o_tick
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            o_time <= INIT_VALUE;
            o_tick <= 0;
        end else begin
            o_tick <= 0;

            if (i_inc) begin
                if (o_time == TICK_COUNT - 1) o_time <= 0;
                else o_time <= o_time + 1;
            end else if (i_dec) begin
                if (o_time == 0) o_time <= TICK_COUNT - 1;
                else o_time <= o_time - 1;
            end else if (i_tick) begin
                if (o_time == TICK_COUNT - 1) begin
                    o_time <= 0;
                    o_tick <= 1;
                end else begin
                    o_time <= o_time + 1;
                end
            end
        end
    end

endmodule



