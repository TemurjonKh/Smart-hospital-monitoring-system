function spo2 = m7_estimate_spo2(ppg)
% M7_ESTIMATE_SPO2  Simulated SpO2 from single PPG channel
%
% CLINICAL NOTE: Real pulse oximetry needs two wavelengths (red + IR).
% This is a simulation only — not for clinical use.
% No toolbox required.

AC = max(ppg) - min(ppg);
DC = mean(ppg);

if DC <= 0
    warning('m7_estimate_spo2: DC <= 0, defaulting DC to 0.01');
    DC = 0.01;
end

% Perfusion Index
PI = (AC / DC) * 100;

% Simulated SpO2: drops slightly when perfusion is very low
spo2_raw = 97.5 - max(0, 1.5 - PI) * 2;
spo2     = max(88, min(100, spo2_raw));

fprintf('[SIMULATED] SpO2: %.1f%%  |  Perfusion Index: %.2f%%\n', spo2, PI);
fprintf('  (NOTE: real SpO2 requires dual-wavelength red+IR PPG)\n');

if spo2 < 90
    fprintf('CRITICAL ALERT: SpO2 below 90%% — hypoxemia\n');
elseif spo2 < 95
    fprintf('WARNING: Low oxygen saturation (%.1f%%)\n', spo2);
else
    fprintf('SpO2 within normal range\n');
end

end