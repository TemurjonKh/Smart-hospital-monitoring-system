function rate = m5_respiration_rate(resp, fs)

% =========================================
% FFT Respiration Rate Estimation
% =========================================

N = length(resp);

Y = fft(resp);

mags = abs(Y/N);

mags = mags(1:floor(N/2)+1);

mags(2:end-1) = 2 * mags(2:end-1);

freqs = fs * (0:floor(N/2)) / N;

% Respiratory frequency range
resp_range = freqs >= 0.1 & freqs <= 0.6;

% Peak detection
[~, idx] = max(mags .* resp_range);

rate = freqs(idx) * 60;

fprintf('Measured respiration rate: %.1f breaths/min\n', ...
    rate);

% =========================================
% Alert Logic
% =========================================

if rate < 12 || rate > 20

    fprintf('ALERT: Abnormal respiration rate!\n');

else

    fprintf('Respiration rate normal.\n');

end

end