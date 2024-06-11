// ---------------------------------------------------------------------------
// 8-bit SPI Slave
// ---------------------------------------------------------------------------
// File Name: spi_slave.v
// Description: This is a Verilog module for an 8-bit SPI slave device, 
//              designed to operate in SPI mode 3 (CPOL = 1, CPHA = 1).
// ---------------------------------------------------------------------------
// Author: Douwe de Vries
// Created: 11/6/2024
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

module spi_slave (
    input wire clk,
    input wire rstn,
    input wire csn,
    input wire sck,
    input wire mosi,
    input wire [7:0] tx_data,
    output wire miso,
    output reg [7:0] rx_data,
    output reg rx_ready
);

    // Analyse sck signal
    reg [2:0] sckr;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sckr <= 3'b000;
        end
        else begin
            sckr <= {sckr[1:0], sck};
        end
    end
    wire sck_risingedge = (sckr[2:1]==2'b01);
    wire sck_fallingedge = (sckr[2:1]==2'b10);

    // Analyse csn signal
    reg [2:0] csnr;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            csnr <= 3'b000;
        end
        else begin
            csnr <= {csnr[1:0], csn};
        end
    end
    wire csn_active = ~csnr[1]; // csn is active low
    wire csn_startmessage = (csnr[2:1]==2'b10);
    // wire csn_endmessage = (csnr[2:1]==2'b01);

    // Counter (8-bit)
    reg [2:0] bitcnt;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bitcnt <= 3'b000;
        end
        else if (!csn_active) begin
            bitcnt <= 3'b000;
        end
        else if (sck_risingedge) begin
            bitcnt <= bitcnt + 3'b001;
        end
    end

    // Input (mosi)
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rx_data <= 8'b00000000;
            rx_ready <= 1'b0;
        end
        else if (sck_risingedge) begin
            rx_data <= {rx_data[6:0], mosi};
            rx_ready <= csn_active && sck_risingedge && (bitcnt==3'b111);
        end
    end

    // Output (miso)
    reg [7:0] miso_shift_reg;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            miso_shift_reg <= 8'b00000000;
        end
        else if (csn_active) begin
            if (sck_fallingedge) begin
                if (bitcnt==3'b000)
                    miso_shift_reg <= tx_data;
                else
                    miso_shift_reg <= {miso_shift_reg[6:0], 1'b0};
            end
        end
    end
    assign miso = miso_shift_reg[7];

endmodule