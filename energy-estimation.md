# SNN Energy Equation

## 1. Baseline Energy (Idle)

Clock period:

$$
T_{\mathrm{clk}} = 10~\mathrm{ns}
$$

### No Clock Gating

$$
50.48~\mu W \times 10~\mathrm{ns}
= 0.5048~\mathrm{pJ/cycle}
$$

### Clock Gating

$$
49.77~\mu W \times 10~\mathrm{ns}
= 0.4977~\mathrm{pJ/cycle}
$$

Therefore,

$$
E_{\mathrm{baseline}} =
\begin{cases}
0.5048NT & \text{No CG}\\
0.4977NT & \text{CG}
\end{cases}
$$

---

## 2. Spike-Dependent Dynamic Energy

Obtained values:

$$
P_{\mathrm{active}} =
\begin{cases}
55.17~\mu W & \text{No CG}\\
64.04~\mu W & \text{CG}
\end{cases}
$$

Active workload:

$$
50~\text{output spikes} \times 4
= 200~\text{input spikes}
$$

Active duration:

$$
6000~\mathrm{ns} = 600~\text{cycles}
$$

### No Clock Gating

$$
55.17~\mu W \times 6000~\mathrm{ns}
= 331.02~\mathrm{pJ}
$$

$$
0.5048 \times 600
= 302.88~\mathrm{pJ}
$$

$$
331.02 - 302.88
= 28.14~\mathrm{pJ}
$$

$$
\frac{28.14}{200}
= 0.1407~\mathrm{pJ/spike}
$$

### Clock Gating

$$
64.04~\mu W \times 6000~\mathrm{ns}
= 384.24~\mathrm{pJ}
$$

$$
0.4977 \times 600
= 298.62~\mathrm{pJ}
$$

$$
384.24 - 298.62
= 85.62~\mathrm{pJ}
$$

$$
\frac{85.62}{200}
= 0.4281~\mathrm{pJ/spike}
$$

---

## 3. Final Energy Model

### No Clock Gating

$$
\boxed{
E_{\mathrm{NoCG}}
=
0.5048NT + 0.1407S
\quad\mathrm{pJ}
}
$$

### Clock Gating

$$
\boxed{
E_{\mathrm{CG}}
=
0.4977NT + 0.4281S
\quad\mathrm{pJ}
}
$$

where:

- $N$ = number of neurons
- $T$ = number of timesteps
- $S$ = total input spike events

---
