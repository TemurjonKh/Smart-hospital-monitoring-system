function rate = m5_respiration_rate(resp, fs)
% M5_RESPIRATION_RATE  Extract breathing rate via FFT peak detection
%
% FIX: previous version used max(mags .* resp_range) which returns
% index 1 (= 0 Hz) whenever DC dominates, giving 0 bpm.
% Now uses index-based search within the respiratory band only.
% No toolbox required.

N     = length(resp);
Y     = fft(resp);
mags  = abs(Y / N);
mags  = mags(1 : floor(N/2) + 1);
mags(2:end-1) = 2 * mags(2:end-1);
freqs = fs * (0 : floor(N/2)) / N;

% Find indices within respiratory range 0.1-0.6 Hz (6-36 bpm)
range_idx = find(freqs >= 0.1 & freqs <= 0.6);

if isempty(range_idx)
    warning('m5_respiration_rate: signal too short to resolve respiratory range.');
    rate = NaN;
    return;
end

[~, local_idx] = max(mags(range_idx));
rate = freqs(range_idx(local_idx)) * 60;

fprintf('Measured respiration rate: %.1f breaths/min\n', rate);

if rate < 12 || rate > 20
    fprintf('ALERT: Abnormal respiration rate! (Normal: 12-20 bpm)\n');
else
    fprintf('Respiration rate normal.\n');
end

end