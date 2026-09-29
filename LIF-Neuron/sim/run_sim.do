# ==============================================================================
# ModelSim DO Script: Run all 4 Gate-Level Simulation Cases
# ==============================================================================

if [file exists work] { vdel -all }
vlib work
vmap work work

set OSU_FREEPDK "$env(FREEPDK45)/osu_soc/lib/files"

# Compile library and testbench once
vlog "$OSU_FREEPDK/gscl45nm.v"
vlog "../tb/tb_LIF_neuron.v"

# ------------------------------------------------------------------------------
# CASE 1: NO-CG | IDLE
# ------------------------------------------------------------------------------
echo "=========================================================="
echo ">>> SIMULATING CASE 1: NO-CG | IDLE <<<"
echo "=========================================================="
vlog "../syn/output_files/LIF_neuron_no_cg.v"
vsim -c -voptargs=+acc tb_LIF_neuron +MODE_IDLE
run -all
file copy -force activity.vcd idle_no_cg.vcd

# ------------------------------------------------------------------------------
# CASE 2: NO-CG | ACTIVE
# ------------------------------------------------------------------------------
echo "=========================================================="
echo ">>> SIMULATING CASE 2: NO-CG | ACTIVE <<<"
echo "=========================================================="
vsim -c -voptargs=+acc tb_LIF_neuron +MODE_ACTIVE
run -all
file copy -force activity.vcd active_no_cg.vcd

# ------------------------------------------------------------------------------
# CASE 3: WITH-CG | IDLE
# ------------------------------------------------------------------------------
echo "=========================================================="
echo ">>> SIMULATING CASE 3: WITH-CG | IDLE <<<"
echo "=========================================================="
vlog "../syn/output_files/LIF_neuron_cg.v"
vsim -c -voptargs=+acc tb_LIF_neuron +MODE_IDLE
run -all
file copy -force activity.vcd idle_cg.vcd

# ------------------------------------------------------------------------------
# CASE 4: WITH-CG | ACTIVE
# ------------------------------------------------------------------------------
echo "=========================================================="
echo ">>> SIMULATING CASE 4: WITH-CG | ACTIVE <<<"
echo "=========================================================="
vsim -c -voptargs=+acc tb_LIF_neuron +MODE_ACTIVE
run -all
file copy -force activity.vcd active_cg.vcd

echo "=========================================================="
echo ">>> ALL 4 SIMULATIONS FINISHED SUCCESSFULLY <<<"
echo "=========================================================="
quit -f