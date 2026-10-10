#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=================================="
echo "TEST 1: Optimized INT8 Multiplier"
echo "=================================="

iverilog -g2012 \
    -s tb_mul8_csa \
    -o sim/mul8_optimized.vvp \
    rtl/optimized/mul8_csa.v \
    tb/tb_mul8_csa.sv

vvp sim/mul8_optimized.vvp

echo
echo "=================================="
echo "TEST 2: Optimized Dot Product"
echo "=================================="

iverilog -g2012 \
    -s tb_dot_product_4lane \
    -o sim/dot_product_optimized.vvp \
    rtl/optimized/dot_product_4lane.v \
    rtl/optimized/mul8_csa.v \
    tb/tb_dot_product_4lane.sv

vvp sim/dot_product_optimized.vvp

echo
echo "=================================="
echo "ALL VERIFICATION TESTS PASSED"
echo "=================================="
