function m6_hrv_metrics(rr_intervals)
% M6_HRV_METRICS  Time-domain and frequency-domain HRV metrics
%
% SYLLABUS LINK (Weeks 6-9 — Fourier Representation):
%   Applies FFT to the RR interval series to extract LF and HF power bands.
%   LF/HF ratio is a clinical marker of autonomic nervous system balance.
%
% No toolbox required.

rr_ms = rr_intervals * 1000;

%% Time-domain metrics
sdnn  = std(rr_ms);
rmssd = sqrt(mean(diff(rr_ms).^2));

% pNN50 — correct denominator is N-1 (number of differences)
rr_diffs = abs(diff(rr_ms));
pnn50    = sum(rr_diffs > 50) / length(rr_diffs) * 100;

fprintf('\n--- HRV Metrics ---\n');
fprintf('Time-domain:\n');
fprintf('  SDNN  : %.2f ms  (Normal > 50 ms — overall HRV)\n', sdnn);
fprintf('  RMSSD : %.2f ms  (Normal > 20 ms — short-term HRV)\n', rmssd);
fprintf('  pNN50 : %.1f %%  (Normal > 3%% — parasympathetic activity)\n', pnn50);

%% Frequency-domain metrics (LF/HF power from RR spectrum)
if length(rr_intervals) > 8
    % Resample RR intervals to uniform 4 Hz grid for FFT
    fs_rr = 4;
    t_rr  = 0 : 1/fs_rr : (length(rr_intervals)-1)/fs_rr;
    rr_uniform = interp1(1:length(rr_intervals), rr_intervals, ...
        linspace(1, length(rr_intervals), length(t_rr)));

    N    = length(rr_uniform);
    Y    = fft(rr_uniform);
    psd  = (abs(Y(1:floor(N/2)+1)).^2) / N;   % power spectral density
    f_ax = fs_rr * (0:floor(N/2)) / N;

    % Integrate power in LF (0.04-0.15 Hz) and HF (0.15-0.4 Hz) bands
    lf_idx  = f_ax >= 0.04 & f_ax <= 0.15;
    hf_idx  = f_ax >= 0.15 & f_ax <= 0.40;
    lf_pow  = sum(psd(lf_idx));
    hf_pow  = sum(psd(hf_idx));
    lf_hf   = lf_pow / (hf_pow + 1e-12);

    fprintf('\nFrequency-domain:\n');
    fprintf('  LF power  : %.4f ms^2  (0.04-0.15 Hz — sympathetic/parasympathetic)\n', lf_pow*1e6);
    fprintf('  HF power  : %.4f ms^2  (0.15-0.40 Hz — parasympathetic/respiratory)\n', hf_pow*1e6);
    fprintf('  LF/HF ratio: %.2f\n', lf_hf);
    if lf_hf > 2.0
        fprintf('  HRV NOTE: High LF/HF — elevated sympathetic tone (stress/pain)\n');
    elseif lf_hf < 0.5
        fprintf('  HRV NOTE: Low LF/HF — parasympathetic dominance (normal rest)\n');
    else
        fprintf('  HRV NOTE: Balanced LF/HF ratio\n');
    end
else
    fprintf('\nFrequency-domain HRV: insufficient RR intervals (need > 8)\n');
end

%% Overall interpretation
fprintf('\nOverall HRV interpretation:\n');
if sdnn < 50
    fprintf('  ALERT: Low SDNN — possible cardiac stress or autonomic dysfunction\n');
elseif sdnn > 100
    fprintf('  Excellent HRV — healthy autonomic nervous system\n');
else
    fprintf('  HRV within normal range\n');
end

end