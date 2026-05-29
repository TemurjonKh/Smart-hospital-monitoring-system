clc;
clear;
close all;

root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'member 1'));
addpath(fullfile(root, 'member 2'));
addpath(fullfile(root, 'member 3'));
addpath(fullfile(root, 'member 4'));
addpath(fullfile(root, 'member 5'));
addpath(fullfile(root, 'member 6'));
addpath(fullfile(root, 'member 7'));
% NOTE: do NOT use addpath(genpath(pwd)) — docs/reference/ would cause
% duplicate function name conflicts.
set(0, 'DefaultFigureWindowStyle', 'docked');

fprintf('=== Smart Hospital Patient Monitoring System ===\n\n');

fs       = 500;   % sampling frequency (Hz)
duration = 10;    % simulation duration (seconds)

%% Member 1: ECG Generation & LTI
fprintf('--- Member 1: ECG Generation & LTI ---\n');
[ecg, t] = m1_generate_ecg(fs, duration);
m1_lti_demo(ecg, t, fs);

%% Member 2: Fourier Analysis
fprintf('\n--- Member 2: Fourier Analysis ---\n');
[freqs, mags] = m2_fft_analysis(ecg, fs);
m2_plot_spectrum(freqs, mags);
is_arr = m2_detect_arrhythmia(ecg, fs);

%% Member 3: Mixed Signals, Filtering & Alert
fprintf('\n--- Member 3: Mixed Signals & Filtering ---\n');
mixed = m3_mix_signals(ecg, t);
clean = m3_butterworth_filter(mixed, fs);
[alert, msg] = m3_smart_alert(mixed, fs);
m2_compare_spectra(mixed, clean, fs);
fprintf('Alert status: %s\n', msg);

% Smart decision — if alert fires, open a visible red warning figure
if alert
    figure('Name', 'HOSPITAL ALERT', 'Color', [0.92 0.1 0.1]);
    axes('Visible', 'off');
    text(0.5, 0.62, '!! PATIENT ALERT !!', ...
         'FontSize', 24, 'FontWeight', 'bold', 'Color', 'white', ...
         'HorizontalAlignment', 'center', 'Units', 'normalized');
    text(0.5, 0.38, msg, ...
         'FontSize', 14, 'Color', 'white', ...
         'HorizontalAlignment', 'center', 'Units', 'normalized');
    fprintf('*** VISUAL ALERT TRIGGERED: %s ***\n', msg);
end

%% Member 4: Transfer Function & Stability
fprintf('\n--- Member 4: Transfer Function & Stability ---\n');
sys = m4_build_tf();
m4_stability_analysis(sys);

%% Member 5: Respiration & Air Quality
fprintf('\n--- Member 5: Respiration & Air Quality ---\n');
[resp, t_resp] = m5_generate_respiration(fs, duration);
rate = m5_respiration_rate(resp, fs);
t_air = linspace(0, 300, 3000);
m5_air_quality_dashboard(t_air);

%% Member 6: HRV Analysis & Dashboard
fprintf('\n--- Member 6: HRV Analysis & Visualization ---\n');
m6_full_dashboard(ecg, t, fs);
[rr_int, rr_t] = m6_extract_rr(ecg, t, fs);
if ~isempty(rr_int)
    m6_hrv_metrics(rr_int);
else
    fprintf('Skipping HRV metrics: no valid RR intervals extracted.\n');
end

%% Member 7: Blood Pressure & SpO2
fprintf('\n--- Member 7: Blood Pressure & SpO2 ---\n');
[ppg, t_ppg] = m7_generate_ppg(fs, duration);
spo2_val = m7_estimate_spo2(ppg);
[sys_bp, dia_bp, map_val] = m7_estimate_blood_pressure(ppg, fs);
m7_vital_dashboard(ppg, t_ppg, fs);

fprintf('\n=== All sections complete ===\n');