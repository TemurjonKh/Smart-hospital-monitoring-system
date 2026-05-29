function [resp, t] = m5_generate_respiration(fs, duration)
% M5_GENERATE_RESPIRATION  Synthetic respiration signal + spectrum
%
% SYLLABUS LINK (Weeks 6-9 — Fourier Representation):
%   Generates a realistic respiration waveform and plots its FFT spectrum,
%   identifying the dominant breathing frequency.
%   Normal adult: 12-20 breaths/min = 0.2-0.33 Hz
%
% No toolbox required.

t      = 0 : 1/fs : duration - 1/fs;
f_resp = 0.25;   % 15 breaths/min

resp = 1.2 * sin(2*pi*f_resp*t)     ...   % main breathing cycle
     + 0.2 * sin(2*pi*2*f_resp*t)   ...   % 2nd harmonic (non-ideal shape)
     + 0.05 * randn(size(t))         ...   % sensor noise
     + 0.1 * sin(2*pi*0.005*t);           % slow baseline drift

fprintf('Respiration signal generated: %.0f breaths/min\n', f_resp*60);

%% Figure 1: Time-domain waveform
figure('Name', 'M5: Respiration Signal');
subplot(2,1,1);
plot(t, resp, 'b', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Amplitude');
title('Respiration Waveform (time domain)');
grid on;

%% Figure panel 2: FFT spectrum of respiration
N     = length(resp);
Y     = fft(resp);
mags  = abs(Y / N);
mags  = mags(1 : floor(N/2)+1);
mags(2:end-1) = 2 * mags(2:end-1);
freqs = fs * (0 : floor(N/2)) / N;

% Find dominant respiratory frequency
range_idx = find(freqs >= 0.1 & freqs <= 0.6);
[~, loc]  = max(mags(range_idx));
dom_freq  = freqs(range_idx(loc));

subplot(2,1,2);
plot(freqs, mags, 'b', 'LineWidth', 1.2);
hold on;
plot(dom_freq, mags(range_idx(loc)), 'rv', 'MarkerSize', 10, 'LineWidth', 2);
text(dom_freq + 0.01, mags(range_idx(loc)), ...
     sprintf(' %.2f Hz (%.0f bpm)', dom_freq, dom_freq*60), ...
     'FontSize', 10, 'Color', 'r');
hold off;
xlim([0 2]);
xlabel('Frequency (Hz)'); ylabel('|X(f)|');
title('Respiration Frequency Spectrum — dominant breathing frequency identified');
grid on;

fprintf('Dominant respiration frequency: %.2f Hz (%.0f breaths/min)\n', ...
    dom_freq, dom_freq*60);

end