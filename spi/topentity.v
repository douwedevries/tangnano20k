module topentity (
    input clk,
    input [1:0] key,
    input spi_clk,
    input spi_cs,
    input spi_mosi,
    output spi_miso,
    output [5:0] led
);

// Reset
wire rstn;
assign rstn = ~key[0];

// Led
reg [5:0] ledr;
assign led = ~ledr;

// SPI Slave
reg [7:0] tx_data;
wire [7:0] rx_data;
wire rx_ready;

spi_slave my_spi (
    .clk(clk),
	.rstn(rstn),
	.csn(spi_cs),
	.sck(spi_clk),
	.mosi(spi_mosi),
	.tx_data(tx_data),
	.miso(spi_miso),
	.rx_data(rx_data),
	.rx_ready(rx_ready)
);

// Sequential code
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        ledr <= 6'b000000;
    end
    else begin
        if (rx_ready == 1) begin
            if (rx_data == 8'h22) begin
                ledr[0] <= 1;
            end

            tx_data = rx_data;
        end
    end
end

// Combinational code

endmodule