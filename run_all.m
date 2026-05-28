clc;
clear;
close all;
% Add all member folders to path
% Get the folder where run_all.m actually lives
root = fileparts(mfilename('fullpath'));

addpath(fullfile(root, 'member 1'));
addpath(fullfile(root, 'member 2'));
addpath(fullfile(root, 'member 3'));
addpath(fullfile(root, 'member 4'));
addpath(fullfile(root, 'member 5'));
addpath(fullfile(root, 'member 6'));
addpath(fullfile(root, 'member 7'));
set(0,'DefaultFigureWindowStyle','docked');

addpath(genpath(pwd));

fprintf('=== Smart Hospital Patient Monitoring System ===\n\n');

%% --- Setup ---
fs       = 500;    % sampling frequency (Hz)
duration = 10;     % simulation duration (seconds)

%% --- MEMBER 1: Generate ECG + LTI Demo ---
fprintf('--- Member 1: ECG Generation & LTI ---\n');
[ecg, t] = m1_generate_ecg(fs, duration);
m1_lti_demo(ecg, t, fs);

%% --- MEMBER 2: Fourier Analysis ---
fprintf('\n--- Member 2: Fourier Analysis ---\n');
[freqs, mags] = m2_fft_analysis(ecg, fs);

m2_plot_spectrum(freqs, mags);
is_arr = m2_detect_arrhythmia(ecg, fs);

%% --- MEMBER 3: Mix + Filter + Alert ---
fprintf('\n--- Member 3: Mixed Signals & Filtering ---\n');
mixed = m3_mix_signals(ecg, t);
clean = m3_butterworth_filter(mixed, fs);
[alert, msg] = m3_smart_alert(mixed, fs);
m2_compare_spectra(mixed, clean, fs);       % compare spectra (M2 function)
fprintf('Alert status: %s\n', msg);

%% --- MEMBER 4: Laplace & Stability ---
fprintf('\n--- Member 4: Laplace Transform ---\n');
sys = m4_build_tf();
m4_stability_analysis(sys);

%% --- MEMBER 5: Respiration + Air Quality ---
fprintf('\n--- Member 5: Respiration & Air Quality ---\n');
[resp, t_resp] = m5_generate_respiration(fs, duration);
rate = m5_respiration_rate(resp, fs);
m5_air_quality_dashboard(t, fs);

%% --- MEMBER 6: HRV & Dashboard ---
fprintf('\n--- Member 6: HRV Analysis & Visualization ---\n');
m6_full_dashboard(ecg, t, fs);
[rr_int, rr_t] = m6_extract_rr(ecg, t, fs);
m6_hrv_metrics(rr_int);

%% --- MEMBER 7: Blood Pressure & SpO2 ---
fprintf('\n--- Member 7: Blood Pressure & SpO2 ---\n');

[ppg, t_ppg] = m7_generate_ppg(fs, duration);

spo2_val = m7_estimate_spo2(ppg);

[sys_bp, dia_bp, map_val] = ...
    m7_estimate_blood_pressure(ppg, fs);

m7_vital_dashboard(ppg, t_ppg, fs);
fprintf('\n=== All sections complete ===\n');
