export DESIGN_NAME = dot_product_4lane
export PLATFORM = nangate45

export VERILOG_FILES = $(DESIGN_HOME)/src/dot_product_4lane_csa/dot_product_4lane_csa.v \
                       $(DESIGN_HOME)/src/dot_product_4lane_csa/mul8_csa.v
export SDC_FILE = $(DESIGN_HOME)/nangate45/dot_product_4lane_2ns/constraint.sdc

export CORE_UTILIZATION = 40
export PLACE_DENSITY_LB_ADDON = 0.20
export TNS_END_PERCENT = 100
export SYNTH_REPEATABLE_BUILD = 1

export PDN_TCL = $(DESIGN_HOME)/nangate45/dot_product_4lane/grid_strategy-M1-M4-M7.tcl
