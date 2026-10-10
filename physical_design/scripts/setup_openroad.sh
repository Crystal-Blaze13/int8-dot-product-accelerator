#!/usr/bin/env bash
set -euo pipefail

PROJECT="$(cd "$(dirname "$0")/../.." && pwd)"
FLOW="${1:-$HOME/OpenROAD-flow-scripts/flow}"

if [[ ! -f "$FLOW/Makefile" ]]; then
    echo "ERROR: OpenROAD flow not found at $FLOW"
    exit 1
fi

DESIGNS="$FLOW/designs"

install_design() {
    local name="$1"
    local source_dir="$2"

    mkdir -p "$DESIGNS/src/$name"
    mkdir -p "$DESIGNS/nangate45/$name"

    cp "$source_dir/dot_product_4lane.v" \
       "$DESIGNS/src/$name/dot_product_4lane.v"

    if [[ -f "$source_dir/mul8_csa.v" ]]; then
        cp "$source_dir/mul8_csa.v" \
           "$DESIGNS/src/$name/mul8_csa.v"
    fi

    cp "$PROJECT/physical_design/configs/constraint.sdc" \
       "$DESIGNS/nangate45/$name/constraint.sdc"

    cp "$PROJECT/physical_design/configs/grid_strategy-M1-M4-M7.tcl" \
       "$DESIGNS/nangate45/$name/grid_strategy-M1-M4-M7.tcl"

    # Build the RTL file list without shell-expanding Make variables.
    local rtl_files
    rtl_files='$(DESIGN_HOME)/src/'"$name"'/dot_product_4lane.v'

    if [[ -f "$source_dir/mul8_csa.v" ]]; then
        rtl_files="$rtl_files"' $(DESIGN_HOME)/src/'"$name"'/mul8_csa.v'
    fi

    cat > "$DESIGNS/nangate45/$name/config.mk" <<CONFIG
export DESIGN_NAME = dot_product_4lane
export PLATFORM = nangate45

export VERILOG_FILES = $rtl_files
export SDC_FILE = \$(DESIGN_HOME)/nangate45/$name/constraint.sdc

export CORE_UTILIZATION = 40
export PLACE_DENSITY_LB_ADDON = 0.20
export TNS_END_PERCENT = 100
export SYNTH_REPEATABLE_BUILD = 1

export PDN_TCL = \$(DESIGN_HOME)/nangate45/$name/grid_strategy-M1-M4-M7.tcl
CONFIG

    echo "Installed: $name"
}

# Baseline
mkdir -p "$PROJECT/physical_design/rtl/baseline"
cp "$PROJECT/rtl/dot_product_4lane.v" \
   "$PROJECT/physical_design/rtl/baseline/dot_product_4lane.v"

install_design "int8_baseline" \
    "$PROJECT/physical_design/rtl/baseline"

# Original carry-save multiplier
install_design "int8_csa" \
    "$PROJECT/physical_design/rtl/original_csa"

# Optimized carry-save multiplier
install_design "int8_csa_opt" \
    "$PROJECT/physical_design/rtl/optimized_csa"

echo
echo "All three OpenROAD designs installed."
echo "Existing flow result directories were not modified."
