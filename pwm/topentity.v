module topentity (
    input clk,
    input [1:0] key,
    input pwm,
    output [5:0] led
);

parameter CLK_FREQ = 50000000;
parameter PWM_FREQ = 20000;
parameter DUTY_CYCLE_WIDTH = 8;

// Reset
wire rstn;
assign rstn = ~key[0];

// Led
reg [5:0] ledr;
assign led = ~ledr;

// PWM
reg [DUTY_CYCLE_WIDTH-1:0] duty_cycle;

pwm  #(
    .CLK_FREQ(CLK_FREQ),
    .PWM_FREQ(PWM_FREQ),
    .DUTY_CYCLE_WIDTH(DUTY_CYCLE_WIDTH)
) my_spi
(
    .clk(clk),
    .rstn(rstn),
    .duty_cycle(duty_cycle),
    .pwm_out(pwm)
);

// Sequential code
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        duty_cycle <= 8'b00000000;
        ledr[0] <= 1'b0;
    end
    else begin
        duty_cycle = 8'b00001111;
        ledr[0] <= 1'b1;
    end
end

// Combinational code

endmodule