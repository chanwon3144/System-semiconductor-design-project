`timescale 1ns / 1ps

module top_watch (
    input        clk,
    input        rst,
    input        btnL,
    input        btnR,
    input        btnU,
    input        btnD,
    input        time_unit,
    input        watch_mode,


    input  [2:0] state_led,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [3:0] led,
    output [2:0] led_pos
);

    wire [3:0] led_mode_bits;
    wire [2:0] led_pos_bits;

    assign led = led_mode_bits;
    assign led_pos = led_pos_bits;

    led_mode U_LED_MODE (
        .sw ({watch_mode, time_unit}),
        .led(led_mode_bits)
    );

    wire btnL_db, btnR_db, btnU_db, btnD_db;

    btn_debounce DB_L (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),
        .o_btn(btnL_db)
    );
    btn_debounce DB_R (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(btnR_db)
    );
    btn_debounce DB_U (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU),
        .o_btn(btnU_db)
    );
    btn_debounce DB_D (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),
        .o_btn(btnD_db)
    );

    wire watch_btnL, watch_btnR, watch_btnU, watch_btnD;
    wire sw_btnL, sw_btnR;

    demux U_DEMUX (
        .btnL(btnL_db),
        .btnR(btnR_db),
        .btnU(btnU_db),
        .btnD(btnD_db),
        .mode_sel(watch_mode),
        .display_sel(time_unit),
        .sw_btnL(sw_btnL),
        .sw_btnR(sw_btnR),
        .watch_btnL(watch_btnL),
        .watch_btnR(watch_btnR),
        .watch_btnU(watch_btnU),
        .watch_btnD(watch_btnD)
    );

    wire [6:0] wt_msec, sw_msec;
    wire [5:0] wt_sec, wt_min, sw_sec, sw_min;
    wire [4:0] wt_hour, sw_hour;

    watch U_WATCH (
        .clk(clk),
        .rst(rst),
        .btnL(watch_btnL),
        .btnR(watch_btnR),
        .btnU(watch_btnU),
        .btnD(watch_btnD),
        .switch({watch_mode, time_unit}),
        .msec(wt_msec),
        .sec(wt_sec),
        .min(wt_min),
        .hour(wt_hour),
        .led(led_pos_bits)
    );

    stopwatch U_STOPWATCH (
        .clk(clk),
        .rst(rst),
        .btnL_Clear(sw_btnL),
        .btnR_RunStop(sw_btnR),
        .switch(time_unit),
        .msec(sw_msec),
        .sec(sw_sec),
        .min(sw_min),
        .hour(sw_hour)
    );
   
    wire [23:0] swatch_data = {sw_hour, sw_min, sw_sec, sw_msec};
    wire [23:0] watch_data = {wt_hour, wt_min, wt_sec, wt_msec};
    wire [23:0] fnd_input_data;

    mux_watch_swatch_sr04_hdt11 U_MUX (
        .sel(watch_mode),
        .swatch_data(swatch_data),
        .watch_data(watch_data),
        .out_data(fnd_input_data)
    );

    wire [6:0] msec_mux;
    wire [5:0] sec_mux, min_mux;
    wire [4:0] hour_mux;

    assign msec_mux = fnd_input_data[6:0];
    assign sec_mux  = fnd_input_data[12:7];
    assign min_mux  = fnd_input_data[18:13];
    assign hour_mux = fnd_input_data[23:19];

    fnd_controller U_FND (
        .clk(clk),
        .reset(rst),
        .switch(time_unit),
        .msec(msec_mux),
        .sec(sec_mux),
        .min(min_mux),
        .hour(hour_mux),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com),


        .rh_data    (rh_data),
        .t_data     (t_data),
        .dht11_done (dht11_done),
        .dht11_valid(dht11_valid) // check sum

    );

endmodule

