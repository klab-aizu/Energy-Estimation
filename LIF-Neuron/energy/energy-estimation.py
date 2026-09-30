import argparse


def main():
    parser = argparse.ArgumentParser(
        description="Calculate SNN Neuron Energy from PrimeTime Power Data"
    )

    parser.add_argument(
        "--power_uw",
        type=float,
        required=True,
        help="Total Power from PrimeTime report in micro-watts (uW)"
    )

    parser.add_argument(
        "--time_ns",
        type=float,
        default=6000.0,
        help="Active measurement window in ns (default: 6000 ns)"
    )

    parser.add_argument(
        "--output_spikes",
        type=float,
        default=50.0,
        help="Number of output spikes during the active window"
    )

    parser.add_argument(
        "--input_per_output",
        type=float,
        default=4.0,
        help="Number of input/synaptic spikes required per output spike"
    )

    parser.add_argument(
        "--clk_period_ns",
        type=float,
        default=10.0,
        help="Clock period in ns (default: 10 ns = 100 MHz)"
    )

    parser.add_argument(
        "--is_idle",
        action="store_true",
        help="Calculate idle/baseline energy instead of active energy"
    )

    args = parser.parse_args()

    # ---------------------------------------------------------
    # Unit conversion
    # ---------------------------------------------------------
    power_watts = args.power_uw * 1e-6
    time_sec = args.time_ns * 1e-9

    print("\n" + "=" * 60)
    print("              SNN ENERGY CALCULATION")
    print("=" * 60)

    print(f"  PrimeTime Power       : {args.power_uw:.4f} uW")

    # =========================================================
    # IDLE / BASELINE
    # =========================================================
    if args.is_idle:

        energy_per_cycle_joules = (
            power_watts * args.clk_period_ns * 1e-9
        )

        energy_fj = energy_per_cycle_joules * 1e15
        energy_pj = energy_per_cycle_joules * 1e12

        print(f"  Condition             : IDLE / BASELINE")
        print(f"  Clock Period          : {args.clk_period_ns:.2f} ns")
        print(f"  Frequency             : "
              f"{1e3 / args.clk_period_ns:.2f} MHz")

        print("-" * 60)

        print(f"  Baseline Energy / Cycle: {energy_fj:.4f} fJ")
        print(f"                          = {energy_pj:.4f} pJ")

        print("-" * 60)
        print("  This represents the baseline energy of one")
        print("  neuron for one clock/timestep.")

    # =========================================================
    # ACTIVE / SPIKING
    # =========================================================
    else:

        # Total energy during active measurement window
        total_energy_joules = power_watts * time_sec
        total_energy_nj = total_energy_joules * 1e9

        # Number of input/synaptic spikes
        total_input_spikes = (
            args.output_spikes * args.input_per_output
        )

        # Energy per output spike
        energy_per_output_joules = (
            total_energy_joules / args.output_spikes
        )

        energy_per_output_pj = (
            energy_per_output_joules * 1e12
        )

        # Energy per input/synaptic spike
        energy_per_input_joules = (
            total_energy_joules / total_input_spikes
        )

        energy_per_input_pj = (
            energy_per_input_joules * 1e12
        )

        print(f"  Condition             : ACTIVE / SPIKING")
        print(f"  Measurement Window    : {args.time_ns:.2f} ns")
        print(f"  Output Spikes         : {int(args.output_spikes)}")
        print(f"  Input Spikes / Output : {args.input_per_output:.0f}")
        print(f"  Total Input Spikes    : "
              f"{int(total_input_spikes)}")

        print("-" * 60)

        print(f"  Total Energy          : {total_energy_nj:.4f} nJ")

        print()
        print(f"  Energy / Input Spike  : "
              f"{energy_per_input_pj:.4f} pJ")
        print(f"  Energy / Output Spike : "
              f"{energy_per_output_pj:.4f} pJ")

        print("-" * 60)

        # Sanity check
        print("  Relationship:")
        print(f"    {energy_per_input_pj:.4f} pJ "
              f"× {args.input_per_output:.0f} inputs")
        print(f"    = {energy_per_output_pj:.4f} pJ / output spike")

    print("=" * 60 + "\n")


if __name__ == "__main__":
    main()
