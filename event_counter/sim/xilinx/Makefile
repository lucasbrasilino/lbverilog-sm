
SRCS =  ../../src/event_counter.v

TESTBENCH = event_counter_tb.v

all: sim

sim: $(SRCS) $(TESTBENCH)
	xvlog  $(SRCS) $(TESTBENCH)
	xelab event_counter_tb -debug typical -R
	
vcd: sim
	xsim --tclbatch xsim.tcl work.event_counter_tb


clean: 
	rm -f *.jou *.log *.wdb *.pb *.str 
	rm -rf xsim.dir .Xil