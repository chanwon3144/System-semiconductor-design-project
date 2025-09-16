`timescale 1ns / 1ps

module watch_cu (
    input clk,
    input rst,
    input i_left,
    input i_right,
    input i_up,
    input i_down,
    output [1:0] sel_pos,
    output o_inc,
    output o_dec
);

    reg [1:0] r_sel_pos;

    always @(posedge clk or posedge rst) begin
        if (rst)
            r_sel_pos <= 0;
        else if (i_left) begin  // 0 → 1 → 2 → 0
            case (r_sel_pos)
                2'd0: r_sel_pos <= 2'd1;
                2'd1: r_sel_pos <= 2'd2;
                2'd2: r_sel_pos <= 2'd0;
            endcase
        end else if (i_right) begin  // 0 → 2 → 1 → 0
            case (r_sel_pos)
                2'd0: r_sel_pos <= 2'd2;
                2'd2: r_sel_pos <= 2'd1;
                2'd1: r_sel_pos <= 2'd0;
            endcase
        end
    end

    assign sel_pos = r_sel_pos;

    // 버튼 상승 에지 감지용 레지스터
    reg prev_up, prev_down;
    reg inc_pulse, dec_pulse;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_up <= 0;
            prev_down <= 0;
            inc_pulse <= 0;
            dec_pulse <= 0;
        end else begin
            prev_up <= i_up;
            prev_down <= i_down;

            inc_pulse <= (i_up && ~prev_up);     // 상승 에지 감지
            dec_pulse <= (i_down && ~prev_down); // 상승 에지 감지
        end
    end

    assign o_inc = inc_pulse;
    assign o_dec = dec_pulse;

endmodule


