`timescale 1ns / 1ps

module switch_controller (
    input clk,
    input rst,
    input [1:0] sw,                    // 물리 스위치 입력: sw[1] = mode, sw[0] = time unit
    input mode_toggle_uart,
    input time_toggle_uart,
    output reg watch_mode,
    output reg time_unit
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            watch_mode <= sw[1];
            time_unit  <= sw[0];
        end else begin
            if (mode_toggle_uart)
                watch_mode <= ~watch_mode;
            if (time_toggle_uart)
                time_unit <= ~time_unit;
        end
    end

endmodule

