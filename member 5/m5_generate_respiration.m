function [resp, t] = m5_generate_respiration(fs, duration)

% =========================================
% Synthetic Respiration Signal
% =========================================

t = 0 : 1/fs : duration - 1/fs;

% Respiration frequency
% 0.25 Hz = 15 breaths/min

f_resp = 0.25;

% Respiration signal
resp = 1.2 * sin(2*pi*f_resp*t) ...
    + 0.2 * sin(2*pi*2*f_resp*t) ...
    + 0.05 * randn(size(t)) ...
    + 0.1 * sin(2*pi*0.005*t);

fprintf('Respiration signal generated: %.0f breaths/min\n', ...
    f_resp*60);

% =========================================
% GRAPH
% =========================================

figure('Name', 'M5: Respiration Signal');

plot(t, resp, 'b');

xlabel('Time (s)');

ylabel('Amplitude');

title('Respiration Waveform');

grid on;

end