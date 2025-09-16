`timescale 1ns / 1ps

module led_mode(
    input [1:0] sw,
    output reg [3:0] led
    );

    always @(*) begin
        case (sw)
            2'b00: led = 4'b0001;  // Stopwatch / msec-sec
            2'b01: led = 4'b0010;  // Stopwatch / hour-min
            2'b10: led = 4'b0100;  // Watch / msec-sec
            2'b11: led = 4'b1000;  // Watch / hour-min
        endcase
    end
endmodule
