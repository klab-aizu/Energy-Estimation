# ==============================================================================
# Script: run_dc.tcl
# Synthesis for LIF_neuron (No-CG and With-CG) using FreePDK45 (gscl45nm.db)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Environment & Library Setup
# ------------------------------------------------------------------------------
set OSU_FREEPDK [format "%s%s" [getenv "FREEPDK45"] "/osu_soc/lib/files"]

set search_path [concat [list . ../rtl] [list $OSU_FREEPDK]]
set alib_library_analysis_path $OSU_FREEPDK

# Use ONLY gscl45nm.db
set target_library [list gscl45nm.db]
set link_library   [concat [list *] $target_library [list dw_foundation.sldb]]

# Working directory for analyzed designs
define_design_lib WORK -path ./WORK

# Design parameters
set TOP_MODULE "LIF_neuron"
set CLK_NAME   "clk"
set CLK_PERIOD 10.0   ;# 10 ns = 100 MHz

# Create directories for outputs and reports
file mkdir ./output_files
file mkdir ./reports

# ------------------------------------------------------------------------------
# 2. Synthesis Procedure
# ------------------------------------------------------------------------------
proc run_synthesis {enable_cg} {
    global TOP_MODULE CLK_NAME CLK_PERIOD

    # Clean memory
    remove_design -designs

    # Analyze RTL files
    analyze -library WORK -format verilog [list ../rtl/common.v ../rtl/LIF.v ../rtl/LIF_neuron.v]
    elaborate $TOP_MODULE -library WORK

    current_design $TOP_MODULE
    link
    uniquify

    # Clock & Timing Constraints
    create_clock -name $CLK_NAME -period $CLK_PERIOD [get_ports $CLK_NAME]
    set_clock_uncertainty 0.1 [get_clocks $CLK_NAME]
    set_clock_transition  0.05 [get_clocks $CLK_NAME]
    set_input_delay  1.0 -clock $CLK_NAME [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
    set_output_delay 1.0 -clock $CLK_NAME [all_outputs]

    # Synthesis selection: Clock-Gating vs No Clock-Gating
    if {$enable_cg == 1} {
        set tag "cg"
        echo "==========================================================="
        echo ">>> SYNTHESIS RUN: WITH CLOCK-GATING (-gate_clock)        <<<"
        echo "==========================================================="
        
        # gscl45nm has no ICG or latch cells, so use combinational (AND-gate) clock gating
        set_clock_gating_style -pos combinational -minimum_bitwidth 2

        # Compile with clock gating
        compile -gate_clock
    } else {
        set tag "no_cg"
        echo "==========================================================="
        echo ">>> SYNTHESIS RUN: WITHOUT CLOCK-GATING                  <<<"
        echo "==========================================================="
        
        # Compile standard
        compile
    }

    # Rename to clean Verilog formatting (no backslashes or escaped names)
    change_names -rules verilog -verbose -hier

    # Export Reports
    report_area                         > ./reports/${TOP_MODULE}_${tag}_area.rpt
    report_timing                       > ./reports/${TOP_MODULE}_${tag}_timing.rpt
    report_power                        > ./reports/${TOP_MODULE}_${tag}_power.rpt
    if {$enable_cg == 1} {
        report_clock_gating -structure  > ./reports/${TOP_MODULE}_${tag}_clock_gating.rpt
    }

    # Export Output Netlists & Constraints
    write -format verilog -hierarchy -output ./output_files/${TOP_MODULE}_${tag}.v
    write -format ddc     -hierarchy -output ./output_files/${TOP_MODULE}_${tag}.ddc
    write_sdc                                ./output_files/${TOP_MODULE}_${tag}.sdc

    echo ">>> Completed synthesis for variant: ${tag} <<<"
}

# ------------------------------------------------------------------------------
# 3. Run Both Versions
# ------------------------------------------------------------------------------
# Case A: Without Clock-Gating
run_synthesis 0

# Case B: With Clock-Gating
run_synthesis 1

echo ">>> ALL SYNTHESIS COMPLETED <<<"
exit