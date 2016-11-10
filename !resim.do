# vsim -f simlibs.f -onfinish final -l vsim.log -voptargs="+acc" -suppress 12003 -sv_seed random +UVM_TESTNAME=net_fpga_cme_test
# -classdebug -uvmcontrol=all
# do wave.do
# view structure
# view wave

# onbreak resume

# run 100
# do wave.do
# run -all

# view wave
# WaveRestoreZoom {1000 ns} {2000 ns}

# VCS
# vsim -f simlibs.f
# run -all