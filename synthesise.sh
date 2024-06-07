#!/bin/bash

BOARD='tangnano20k'
DEVICE='GW2AR-LV18QN88C8/I7'
FAMILY='GW2A-18C'

# Verilog RTL synthesis
read -p "Press Enter to start yosys RTL synthesis..."
# yosys -D LEDS_NR=6 -p "read_verilog topentity.v; synth_gowin -json topentity.json"
yosys -p "read_verilog topentity.v; synth_gowin -json topentity.json"

# FPGA place and route
read -p "Press Enter to start nextpnr place and route..."
nextpnr-himbaechel --json topentity.json \
                   --write pnrtopentity.json \
                   --device $DEVICE \
                   --vopt family=$FAMILY \
                   --vopt cst=$BOARD.cst

# Gowin FPGA bitstream
read -p "Press Enter to start Gowin bitstream generation..."
gowin_pack -d $FAMILY -o pack.fs pnrtopentity.json

# Optionally unpack and visualize
# read -p "Press Enter to unpack and visualize..."
# gowin_unpack -d $DEVICE -o unpack.v pack.fs
# yosys -p "read_verilog -lib +/gowin/cells_sim.v; clean -purge; show" unpack.v

# Programming FPGA
read -p "Press Enter to program FPGA..."
# openFPGALoader -b tangnano20k pack.fs
openFPGALoader -d /dev/ttyUSB0 pack.fs