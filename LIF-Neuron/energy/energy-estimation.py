"""
Energy Estimation Script for LIF Neuron
Calculates:
  - Energy per spike (Active mode, with and without Clock-Gating)
  - Energy per clock cycle (Idle mode, with and without Clock-Gating)
  - Power / Energy reduction percentage
"""

#!/usr/bin/env python3
import argparse

def main():
    parser = argparse.ArgumentParser(description="Calculate Energy per Spike from Power Data")
    parser.add_argument("--power_uw", type=float, required=True, 
                        help="Total Power from PrimeTime report in micro-watts (uW) (e.g. 64.04)")
    parser.add_argument("--time_ns", type=float, default=3565.0, 
                        help="Total simulation window duration in ns (default: 3565 ns)")
    parser.add_argument("--spikes", type=float, default=50.0, 
                        help="Number of spikes fired during the window (default: 50)")
    parser.add_argument("--clk_period_ns", type=float, default=10.0, 
                        help="Clock period in ns (default: 10 ns = 100 MHz)")
    parser.add_argument("--is_idle", action="store_true", 
                        help="Add this flag if calculating for the Idle/No-Spike case")

    args = parser.parse_args()

    # Convert to standard units: Watts and Seconds
    power_watts = args.power_uw * 1e-6
    time_sec = args.time_ns * 1e-9

    print("\n" + "=" * 50)
    print("           ENERGY CALCULATION RESULT            ")
    print("=" * 50)
    print(f"  Input Power         : {args.power_uw:.4f} uW")
    
    if args.is_idle:
        # For Idle: Energy consumed per clock cycle (spikes = 0)
        energy_per_cycle_joules = power_watts * (args.clk_period_ns * 1e-9)
        energy_fj = energy_per_cycle_joules * 1e15
        print(f"  Condition           : IDLE (No Spikes)")
        print(f"  Clock Period        : {args.clk_period_ns} ns")
        print(f"  Energy per Cycle    : {energy_fj:.4f} fJ / cycle")
    else:
        # For Active: Energy per spike = (Power * Total_Time) / Num_Spikes
        total_energy_joules = power_watts * time_sec
        energy_per_spike_joules = total_energy_joules / args.spikes
        energy_pj = energy_per_spike_joules * 1e12
        print(f"  Condition           : ACTIVE (Spikes)")
        print(f"  Measurement Window  : {args.time_ns} ns")
        print(f"  Total Spikes Fired  : {int(args.spikes)}")
        print(f"  Total Energy        : {total_energy_joules * 1e9:.4f} nJ")
        print(f"  Energy per 1 Spike  : {energy_pj:.4f} pJ / spike")

    print("=" * 50 + "\n")

if __name__ == "__main__":
    main()