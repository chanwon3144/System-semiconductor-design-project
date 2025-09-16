`timescale 1ns / 1ps

module fnd_controller (
    input       clk,
    input       reset,
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    input       switch,

    input [7:0] rh_data,
    input [7:0] t_data,
    input       dht11_done,
    input       dht11_valid, // check sum

    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [3:0] w_dht, w_bcd, w_bcd_L, w_bcd_H, w_msec_1, w_msec_10, w_sec_1, w_sec_10, w_min_1, w_min_10, w_hour_1, w_hour_10, w_rh_1, w_rh_10, w_t_1, w_t_10;
    wire w_oclk;
    wire [3:0] w_cmp;
    wire [2:0] fnd_sel;


    clk_div U_CLK_Div (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_oclk)
    );
    counter_8 U_Counter_8 (
        .clk(w_oclk),
        .reset(reset),
        .fnd_sel(fnd_sel)
    );
    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)
    );

    digit_splitter #(
        .BIT_WIDTH(7)
    ) U_DS_RH (
        .time_data(rh_data),
        .digit_1  (w_rh_1),
        .digit_10 (w_rh_10)
    );

    digit_splitter #(
        .BIT_WIDTH(7)
    ) U_DS_T (
        .time_data(t_data),
        .digit_1  (w_t_1),
        .digit_10 (w_t_10)
    );

    mux_4x1 U_DHT11 (
        .sel(fnd_sel[1:0]),
        .digit_1(w_t_1),
        .digit_10(w_t_10),
        .digit_100(w_rh_1),
        .digit_1000(w_rh_10),
        .bcd(w_dht)
    );

    digit_splitter #(
        .BIT_WIDTH(7)
    ) U_DS_MSEC (
        .time_data(msec),
        .digit_1  (w_msec_1),
        .digit_10 (w_msec_10)
    );


    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_SEC (
        .time_data(sec),
        .digit_1  (w_sec_1),
        .digit_10 (w_sec_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_MIN (
        .time_data(min),
        .digit_1  (w_min_1),
        .digit_10 (w_min_10)
    );

    digit_splitter #(
        .BIT_WIDTH(5)
    ) U_DS_HOUR (
        .time_data(hour),
        .digit_1  (w_hour_1),
        .digit_10 (w_hour_10)
    );

    comparator U_Cmp (
        .msec_data(msec),
        .sel(w_cmp)
    );

    mux_8x1 U_MUXL_8x1 (
        .sel(fnd_sel),
        .dot(w_cmp),
        .digit_1(w_msec_1),
        .digit_10(w_msec_10),
        .digit_100(w_sec_1),
        .digit_1000(w_sec_10),
        .bcd(w_bcd_L)
    );

    mux_8x1 U_MUXH_8x1 (
        .sel(fnd_sel),
        .dot(w_cmp),
        .digit_1(w_min_1),
        .digit_10(w_min_10),
        .digit_100(w_hour_1),
        .digit_1000(w_hour_10),
        .bcd(w_bcd_H)
    );

    mux_2x1 U_MUX_2x1 (
        .switch(switch),
        .bcd_L(w_bcd_L),
        .bcd_H(w_bcd_H),
        .bcd(w_bcd)
    );

    bcd U_BCD (
        .bcd(w_dht),
        .fnd_data(fnd_data)
    );
endmodule

// clk divider
// 1khz
module clk_div (
    input  clk,
    input  reset,
    output o_clk
);
    // clk 100_000_000, r_count = 100_000
    //reg [16:0] r_counter;
    reg [$clog2(100_000)-1:0] r_counter;
    reg r_clk;

    assign o_clk = r_clk;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk     <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin  // 1khz period
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end

endmodule

// 8진 카운터
module counter_8 (
    input        clk,
    input        reset,
    output [2:0] fnd_sel
);
    reg [2:0] r_counter;
    assign fnd_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule

module decoder_2x4 (
    input      [1:0] fnd_sel,
    output reg [3:0] fnd_com
);
    always @(fnd_sel) begin
        case (fnd_sel)
            2'b00:   fnd_com = 4'b1110;  // fnd 1의 자리 On,
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end
endmodule

module comparator (
    input  [6:0] msec_data,
    output [3:0] sel
);
    assign sel = (msec_data >= 50) ? 4'h0a : 4'h0b;
endmodule

module mux_2x1 (
    input        switch,
    input  [3:0] bcd_L,
    input  [3:0] bcd_H,
    output [3:0] bcd
);
    assign bcd = (switch == 0) ? bcd_L : bcd_H;

endmodule

module mux_4x1 (
    input  [1:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    // 8:1 mux , always 
    always @(*) begin
        case (sel)
            2'b00: r_bcd = digit_1;
            2'b01: r_bcd = digit_10;
            2'b10: r_bcd = digit_100;
            2'b11: r_bcd = digit_1000;
        endcase
    end
endmodule

module mux_8x1 (
    input  [2:0] sel,
    input  [3:0] dot,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    // 8:1 mux , always 
    always @(*) begin
        case (sel)
            3'b000: r_bcd = digit_1;
            3'b001: r_bcd = digit_10;
            3'b010: r_bcd = digit_100;
            3'b011: r_bcd = digit_1000;
            3'b100: r_bcd = 4'h0b;
            3'b101: r_bcd = 4'h0b;
            3'b110: r_bcd = dot;
            3'b111: r_bcd = 4'h0b;
        endcase
    end

endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input  [BIT_WIDTH -1:0] time_data,
    output [           3:0] digit_1,
    output [           3:0] digit_10
);

    assign digit_1  = time_data % 10;
    assign digit_10 = (time_data / 10) % 10;

endmodule



module bcd (
    input  [3:0] bcd,
    output [7:0] fnd_data
);

    reg [7:0] r_fnd_data;

    assign fnd_data = r_fnd_data;

    // 조합논리 combinational , 행위수준 모델링.

    always @(bcd) begin
        case (bcd)
            4'h00:   r_fnd_data = 8'hc0;
            4'h01:   r_fnd_data = 8'hf9;
            4'h02:   r_fnd_data = 8'ha4;
            4'h03:   r_fnd_data = 8'hb0;
            4'h04:   r_fnd_data = 8'h99;
            4'h05:   r_fnd_data = 8'h92;
            4'h06:   r_fnd_data = 8'h82;
            4'h07:   r_fnd_data = 8'hf8;
            4'h08:   r_fnd_data = 8'h80;
            4'h09:   r_fnd_data = 8'h90;
            4'h0a:   r_fnd_data = 8'h7f;
            4'h0b:   r_fnd_data = 8'hff;
            default: r_fnd_data = 8'hff;
        endcase
    end
endmodule

