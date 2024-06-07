module topentity (
    input clk,
    input [1:0] key,
    output [5:0] led
);

// Reset
wire rstn;
assign rstn = ~key[0];

// Counters
reg [25:0] ctr_q;
wire [25:0] ctr_d;

// Sequential code
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        ctr_q = 0;
    end
    else begin
        if (key[1]) begin
            ctr_q <= ctr_d;
        end
    end
end

// Combinational code
assign ctr_d = ctr_q + 1'b1;
assign led[5:0] = ctr_q[25:20];

endmodule
