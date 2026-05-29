# Smart Hospital Patient Monitoring System

A MATLAB simulation of a smart hospital that processes patient vital signs,
detects anomalies, and visualises results through interactive dashboards.
Built across 7 members, each covering a distinct syllabus topic.

---

## How to run

```matlab
cd path/to/hospital
run_all        % runs all members in sequence
```

Or open `SmartHospital.mlapp` in MATLAB App Designer for the interactive UI.

---

## Requirement 1 — Time-domain LTI systems (Weeks 1–4)

**Scenario:** A patient's ECG signal is modelled as an LTI system.
The hospital monitor must smooth the signal (convolution), detect delays
between electrode channels (time shifting), and normalise amplitude
ranges across different patients (scaling).

**What the code does:**
- `m1_generate_ecg.m` — builds ECG as a superposition of sinusoidal harmonics
- `m1_lti_demo.m` — demonstrates all four LTI properties:
  1. **Impulse response** `h[n]` — 5-point moving average filter
  2. **Convolution** — ECG passed through `h[n]` to smooth R-peak noise
  3. **Time shifting** — signal delayed by 0.2 s (electrode lag simulation)
  4. **Scaling** — amplitude scaled by 1.5× (gain normalisation)
  5. **Superposition** — proves `T{x1+x2} = T{x1} + T{x2}` numerically

---

## Requirement 2 — Fourier representation (Weeks 6–9)

**Scenario:** A cardiologist needs to identify whether a patient's heart
rhythm is normal (48–120 bpm). Noise from power-line interference (60 Hz)
and patient breathing (0.25 Hz) must be separated from the cardiac signal
using frequency-domain analysis.

**What the code does:**
- `m2_fft_analysis.m` — computes single-sided FFT magnitude spectrum
- `m2_detect_arrhythmia.m` — identifies dominant frequency in cardiac band
  (0.5–4 Hz) and flags if outside normal sinus rhythm range
- `m2_compare_spectra.m` — side-by-side before/after filtering spectrum
- `m5_generate_respiration.m` — plots respiration FFT showing 0.25 Hz peak
- `m6_hrv_metrics.m` — computes LF power (0.04–0.15 Hz), HF power
  (0.15–0.4 Hz), and LF/HF ratio (autonomic nervous system balance)

---

## Requirement 3 — Mixed signal classes & smart decisions (Weeks 10–12)

**Scenario:** A real hospital sensor receives a composite signal containing
ECG, patient breathing, baseline wander from body temperature changes,
and 60 Hz power-line interference. The system must denoise the signal
and automatically trigger alerts for abnormal conditions.

**What the code does:**
- `m3_mix_signals.m` — combines ECG + respiration (0.25 Hz) +
  temperature drift (0.02 Hz) + EMI noise (60 Hz)
- `m3_butterworth_filter.m` — toolbox-free zero-phase bandpass (0.5–33 Hz):
  - Stage 1: IIR highpass removes DC and baseline wander
  - Stage 2: Moving-average lowpass removes 60 Hz EMI (~35 dB attenuation)
- `m3_smart_alert.m` — three-layer decision logic:
  - Flatline detection (sensor disconnected)
  - Abnormal spike detection (electrode pop or artefact)
  - Noise ratio check (signal quality assessment)
- `run_all.m` — when alert fires, a **red warning figure** pops up with
  the alert message (not just a text print — a visual action)
- `m5_air_quality_dashboard.m` — monitors room CO2 and temperature,
  triggers alerts if thresholds are exceeded
- `m7_estimate_blood_pressure.m` / `m7_estimate_spo2.m` — derives SpO2
  and blood pressure from PPG signal with hypertension/hypoxemia alerts

---

## Requirement 4 — Laplace transform & stability (Week 13)

**Scenario:** An IV drug infusion pump must deliver medication at a rate
that brings the patient's blood concentration to a target level without
overshoot (overdose) or undershoot (underdosing). A PI controller is
designed and its stability is analysed in the Laplace domain.

**Laplace transform connection:**
In the time domain, drug concentration dynamics obey:
```
tau * dC/dt + C(t) = K * u(t)
```
Taking the Laplace Transform (using `L{dC/dt} = s·C(s)`):
```
(tau·s + 1) · C(s) = K · U(s)
→ G(s) = C(s)/U(s) = K / (tau·s + 1)    [plant transfer function]
```
With PI controller `C(s) = (s + 0.25)/s`, the closed-loop is computed
by polynomial arithmetic — no toolbox required.

**What the code does:**
- `m4_build_tf.m` — derives closed-loop TF from pharmacokinetic model
- `m4_stability_analysis.m` — analyses the control loop:
  - Poles (stability check — all must have negative real parts)
  - DC gain and steady-state error
  - Gain margin and phase margin (from Bode plot)
  - Settling time (how long until drug concentration stabilises)
  - Step response simulated via Euler integration (no toolbox)

---

## Submission checklist

| Item | Status |
|------|--------|
| Fully commented MATLAB code | ✅ All 22 .m files |
| MATLAB App Designer UI | ✅ SmartHospital.mlapp + reference code |
| Scenario tied to syllabus | ✅ This README |
| Convolution demonstrated | ✅ m1_lti_demo.m |
| Fourier analysis demonstrated | ✅ m2_fft_analysis.m, m5, m6 |
| Filtering and denoising | ✅ m3_butterworth_filter.m |
| Smart decision/alert | ✅ m3_smart_alert.m + visual alert in run_all |
| Laplace/stability analysis | ✅ m4_build_tf.m + m4_stability_analysis.m |
| Visual dashboards | ✅ M5, M6, M7 dashboards |
| No toolbox dependencies | ✅ Base MATLAB only |

---

## Project structure

```
hospital/
├── run_all.m                          ← master script
├── SmartHospital.mlapp                ← App Designer UI
├── SmartHospitalApp_CODE_REFERENCE.m  ← App callback code
├── README.md
├── member 1/   m1_generate_ecg.m  m1_lti_demo.m
├── member 2/   m2_fft_analysis.m  m2_detect_arrhythmia.m
│               m2_plot_spectrum.m  m2_compare_spectra.m
├── member 3/   m3_mix_signals.m  m3_butterworth_filter.m  m3_smart_alert.m
├── member 4/   m4_build_tf.m  m4_stability_analysis.m
├── member 5/   m5_generate_respiration.m  m5_respiration_rate.m
│               m5_air_quality_dashboard.m
├── member 6/   m6_extract_rr.m  m6_hrv_metrics.m  m6_full_dashboard.m
├── member 7/   m7_generate_ppg.m  m7_estimate_spo2.m
│               m7_estimate_blood_pressure.m  m7_vital_dashboard.m
└── references/ (original reference files — not on MATLAB path)
```