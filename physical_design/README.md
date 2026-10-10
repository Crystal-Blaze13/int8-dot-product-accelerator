# Reproducing the Physical-Design Experiments

## Requirements

- OpenROAD-flow-scripts
- Nangate45 platform
- Yosys and OpenROAD
- Icarus Verilog for functional verification

The experiments use a 2 ns clock constraint (500 MHz).

## Setup

From the project root:

    ./physical_design/scripts/setup_openroad.sh

The script installs three independent designs:

- int8_baseline: inferred signed multipliers
- int8_csa: Baugh-Wooley carry-save multipliers
- int8_csa_opt: optimized carry-save multipliers

## Synthesis

From the OpenROAD-flow-scripts/flow directory:

    make DESIGN_CONFIG=designs/nangate45/int8_baseline/config.mk FLOW_VARIANT=repro_int8_baseline synth

    make DESIGN_CONFIG=designs/nangate45/int8_csa/config.mk FLOW_VARIANT=repro_int8_csa synth

    make DESIGN_CONFIG=designs/nangate45/int8_csa_opt/config.mk FLOW_VARIANT=repro_int8_csa_opt synth

Use unique FLOW_VARIANT names to prevent Make from reusing outputs across configurations with the same DESIGN_NAME.

## Full RTL-to-GDSII

To execute the complete physical-design flow, omit the synth target.

For example:

    make DESIGN_CONFIG=designs/nangate45/int8_csa_opt/config.mk FLOW_VARIANT=full_int8_csa_opt

## Reference Results

| Architecture | Synthesis area (um²) | Final cell area (um²) |
|---|---:|---:|
| Baseline | 2974.146 | 3091 |
| Original CSA | 2793.266 | 2983 |
| Optimized CSA | 2784.488 | 2966 |

The original experiments completed routing with zero final routing violations and met the 500 MHz timing target.

Synthesis was independently reproduced for all three architectures with identical reported cell areas.

The new packaged configurations have not yet been rerun through the complete physical-design flow.

## Verification

From the project root:

    ./scripts/run_tests.sh

This runs exhaustive signed INT8 multiplier testing and the complete dot-product accelerator testbench.
