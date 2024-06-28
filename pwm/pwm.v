// ---------------------------------------------------------------------------
// PWM
// ---------------------------------------------------------------------------
// File Name: PWM.v
// Description: This is a PWM module which converts the system clock
//              to a lower PWM frequency with desired duty cycle.
// ---------------------------------------------------------------------------
// Author: Douwe de Vries
// Created: 28/6/2024
// ---------------------------------------------------------------------------
// MIT License
// 
// Copyright (c) 2024 Douwe de Vries
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ---------------------------------------------------------------------------

module pwm
    #(parameter
        CLK_FREQ = 50000000,  // System clock frequency in Hz
        PWM_FREQ = 20000,     // Desired PWM frequency in Hz
        DUTY_CYCLE_WIDTH = 8  // 8-bit duty cycle
    )
    (
        input wire clk,                                 // System clock
        input wire rstn,                                // Asynchronous reset
        input wire [DUTY_CYCLE_WIDTH-1:0] duty_cycle,   // Duty cycle (0-255)
        output reg pwm_out                              // PWM output
    );

    localparam integer COUNTER_MAX = CLK_FREQ / PWM_FREQ - 1;
    localparam integer COUNTER_WIDTH = $clog2(COUNTER_MAX + 1);

    reg [COUNTER_WIDTH-1:0] counter;

    // Counter
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            counter <= 0;
        end
        else begin
            if (counter < COUNTER_MAX) begin
                counter <= counter + 1;
            end
            else begin
                counter <= 0;
            end
        end
    end

    // PWM output
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pwm_out <= 0;
        end
        else begin
            if (duty_cycle == {DUTY_CYCLE_WIDTH{1'b1}}) begin
                pwm_out <= 1;
            end
            else if (counter < ((duty_cycle * (COUNTER_MAX + 1)) >> DUTY_CYCLE_WIDTH)) begin
                pwm_out <= 1;
            end
            else begin
                pwm_out <= 0;
            end
        end
    end

endmodule