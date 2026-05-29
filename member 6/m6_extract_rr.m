function [rr_intervals, rr_times] = m6_extract_rr(ecg, t, fs)

% =========================================
% Toolbox-free R-peak detection
% =========================================

threshold = mean(ecg) + 1.5 * std(ecg);

min_dist = round(0.4 * fs);

peak_locs = [];

% Simple local maximum detection
for i = 2:length(ecg)-1

    if ecg(i) > threshold && ...
            ecg(i) > ecg(i-1) && ...
            ecg(i) > ecg(i+1)

        if isempty(peak_locs) || ...
                (i - peak_locs(end)) > min_dist

            peak_locs(end+1) = i;

        end
    end
end

% =========================================
% RR Intervals
% =========================================

if length(peak_locs) < 2
    warning('m6_extract_rr: fewer than 2 R-peaks detected — check signal quality.');
    rr_intervals = [];
    rr_times     = [];
    fprintf('R-peaks detected: %d (insufficient for RR analysis)\n', length(peak_locs));
    return;
end

rr_intervals = diff(t(peak_locs));

rr_times = t(peak_locs(1:end-1));

fprintf('R-peaks detected: %d\n', length(peak_locs));

fprintf('Mean RR interval: %.3f s (%.0f bpm)\n', ...
    mean(rr_intervals), ...
    60/mean(rr_intervals));

end