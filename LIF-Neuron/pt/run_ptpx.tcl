# ==============================================================================
# Script: run_ptpx.tcl
# Synopsys PrimeTime PX Power Analysis for LIF_neuron (4 Cases)
# ==============================================================================

set power_enable_analysis TRUE
set power_analysis_mode   averaged

set OSU_FREEPDK [format "%s%s" [getenv "FREEPDK45"] "/osu_soc/lib/files"]
set search_path [concat [list . ../syn/output_files ../sim] [list $OSU_FREEPDK]]

set target_library [list gscl45nm.db]
set link_library   [concat [list *] $target_library]

set TOP_MODULE "LIF_neuron"
set STRIP_PATH "tb_LIF_neuron/dut"

file mkdir ./reports

# ------------------------------------------------------------------------------
# Procedure to analyze power for a specific scenario
# ------------------------------------------------------------------------------
proc analyze_power {tag netlist_file vcd_file sdc_file} {
    global TOP_MODULE STRIP_PATH

    remove_design -all

    echo "=========================================================="
    echo ">>> RUNNING PTPX FOR CASE: ${tag} <<<"
    echo "=========================================================="

    read_verilog $netlist_file
    current_design $TOP_MODULE
    link

    read_sdc $sdc_file
    check_timing
    update_timing

    read_vcd -strip_path $STRIP_PATH $vcd_file
    check_power
    update_power

    report_power -hierarchy > ./reports/power_${tag}_hier.rpt
    report_power            > ./reports/power_${tag}.rpt

    echo ">>> Finished power analysis for: ${tag} <<<"
}

# ------------------------------------------------------------------------------
# Run All 4 Combinations
# ------------------------------------------------------------------------------
# Case 1: No Clock-Gating | Idle
analyze_power "idle_no_cg"   "../syn/output_files/LIF_neuron_no_cg.v" "../sim/idle_no_cg.vcd"   "../syn/output_files/LIF_neuron_no_cg.sdc"

# Case 2: No Clock-Gating | Active
analyze_power "active_no_cg" "../syn/output_files/LIF_neuron_no_cg.v" "../sim/active_no_cg.vcd" "../syn/output_files/LIF_neuron_no_cg.sdc"

# Case 3: With Clock-Gating | Idle
analyze_power "idle_cg"      "../syn/output_files/LIF_neuron_cg.v"    "../sim/idle_cg.vcd"      "../syn/output_files/LIF_neuron_cg.sdc"

# Case 4: With Clock-Gating | Active
analyze_power "active_cg"    "../syn/output_files/LIF_neuron_cg.v"    "../sim/active_cg.vcd"    "../syn/output_files/LIF_neuron_cg.sdc"

echo "=========================================================="
echo ">>> ALL 4 POWER ANALYSES COMPLETED SUCCESSFULLY <<<"
echo "=========================================================="
exit
