# vlib work

# vlog $env(XILINX_VIVADO)/data/verilog/src/glbl.v

# vlog $env(XILINX_VIVADO)/data/verilog/src/glbl.v
# vlog -work work -novopt -lint -nocovercells -nocoverfec -nocovershort -f list.f -pedanticerrors +define+QUESTASIM

# vlog +incdir+../../../net_fpga/rtl +incdir+../../tb +define+CME_TB -lint -sv -f list.f -suppress 12012,2583,12003


# vlog -lint -sv -f list.f



# VCS
# vlog -f list.f
