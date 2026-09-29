cat << 'EOF' > run_sim.sh
#!/bin/bash
set -e

echo "=========================================================="
echo ">>> STEP 2: GATE-LEVEL SIMULATIONS (4 CASES)          <<<"
echo "=========================================================="

OSU_FREEPDK="$FREEPDK45/osu_soc/lib/files"

# 1. Clean & setup workspace
rm -rf work activity.vcd *.vcd
vlib work
vmap work work

# 2. Compile standard cell models and testbench
echo ">>> Compiling cell library and testbench..."
vlog "$OSU_FREEPDK/gscl45nm.v"
vlog ../tb/tb_LIF_neuron.v

# ------------------------------------------------------------------------------
# CASE 1: NO-CG | IDLE
# ------------------------------------------------------------------------------
echo "=========================================================="
echo ">>> SIMULATING CASE 1: NO-CG | IDLE                   <<<"
echo "=========================================================="
vlog ../syn/output_files/LIF_neuron_no_cg.v
vsim -c -voptargs=+acc tb_LIF_neuron +MODE_IDLE -do "run -all; quit -f"
mv activity.vcd idle_no_cg.vcd

# ------------------------------------------------------------------------------
# CASE 2: NO-CG | ACTIVE
# ------------------------------------------------------------------------------
echo "=========================================================="
echo ">>> SIMULATING CASE 2: NO-CG | ACTIVE                 <<<"
echo "=========================================================="
vsim -c -voptargs=+acc tb_LIF_neuron +MODE_ACTIVE -do "run -all; quit -f"
mv activity.vcd active_no_cg.vcd

# ------------------------------------------------------------------------------
# CASE 3: WITH-CG | IDLE
# ------------------------------------------------------------------------------
echo "=========================================================="
echo ">>> SIMULATING CASE 3: WITH-CG | IDLE                 <<<"
echo "=========================================================="
vlog ../syn/output_files/LIF_neuron_cg.v
vsim -c -voptargs=+acc tb_LIF_neuron +MODE_IDLE -do "run -all; quit -f"
mv activity.vcd idle_cg.vcd

# ------------------------------------------------------------------------------
# CASE 4: WITH-CG | ACTIVE
# ------------------------------------------------------------------------------
echo "=========================================================="
echo ">>> SIMULATING CASE 4: WITH-CG | ACTIVE               <<<"
echo "=========================================================="
vsim -c -voptargs=+acc tb_LIF_neuron +MODE_ACTIVE -do "run -all; quit -f"
mv activity.vcd active_cg.vcd

# ------------------------------------------------------------------------------
# Final Verification
# ------------------------------------------------------------------------------
echo "=========================================================="
echo ">>> ALL 4 SIMULATIONS COMPLETE! GENERATED VCD FILES:   <<<"
echo "=========================================================="
ls -lh *.vcd
EOF

chmod +x run_sim.sh
./run_sim.sh