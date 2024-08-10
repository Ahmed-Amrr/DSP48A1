vlib work
vlog DSP48A1.v DSP48A1_tb.v pipeline_mux.v
vsim -voptargs=+acc work.DSP48A1_tb
add wave -position insertpoint  \
sim:/DSP48A1_tb/A \
sim:/DSP48A1_tb/B \
sim:/DSP48A1_tb/BCIN \
sim:/DSP48A1_tb/D \
sim:/DSP48A1_tb/C \
sim:/DSP48A1_tb/PCIN \
sim:/DSP48A1_tb/opmode \
sim:/DSP48A1_tb/CARRYIN \
sim:/DSP48A1_tb/clk \
sim:/DSP48A1_tb/P \
sim:/DSP48A1_tb/PCOUT \
sim:/DSP48A1_tb/BCOUT \
sim:/DSP48A1_tb/M \
sim:/DSP48A1_tb/CARRYOUT \
sim:/DSP48A1_tb/CARRYOUTF
run -all
#quit -sim