function m6_full_dashboard(ecg, t, fs)
% M6_FULL_DASHBOARD  HRV visualization dashboard
% FIX: all panels now guarded against empty rr_int array.
% No toolbox required.

[rr_int, rr_t] = m6_extract_rr(ecg, t, fs);

figure('Name', 'M6: HRV Dashboard');

%% ECG signal
subplot(3,2,[1 2]);
plot(t, ecg, 'b');
title('ECG Signal');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

%% RR Tachogram
subplot(3,2,3);
if ~isempty(rr_int)
    plot(rr_t, rr_int*1000, 'ro-');
    yline(mean(rr_int)*1000, 'b--', 'Mean');
    title('RR Interval Tachogram');
else
    text(0.3, 0.5, 'Insufficient R-peaks', 'Units', 'normalized');
    title('RR Tachogram (no data)');
end
xlabel('Time (s)'); ylabel('RR Interval (ms)'); grid on;

%% RR Histogram
subplot(3,2,4);
if ~isempty(rr_int)
    histogram(rr_int*1000, 15);
    title('RR Interval Histogram');
else
    text(0.3, 0.5, 'Insufficient R-peaks', 'Units', 'normalized');
    title('RR Histogram (no data)');
end
xlabel('RR Interval (ms)'); ylabel('Count'); grid on;

%% HRV Frequency Spectrum
subplot(3,2,[5 6]);
if length(rr_int) > 8
    fs_rr = 4;
    t_rr  = 0 : 1/fs_rr : (length(rr_int)-1)/fs_rr;
    rr_resampled = interp1(1:length(rr_int), rr_int, ...
        linspace(1, length(rr_int), length(t_rr)));
    N    = length(rr_resampled);
    Y    = fft(rr_resampled);
    mags = 2*abs(Y(1:floor(N/2)+1))/N;
    f_ax = fs_rr*(0:floor(N/2))/N;
    plot(f_ax, mags, 'k'); hold on;
    patch([0.04 0.15 0.15 0.04], [0 0 max(mags) max(mags)], ...
          'b', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    patch([0.15 0.40 0.40 0.15], [0 0 max(mags) max(mags)], ...
          'r', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    hold off;
    legend('Spectrum', 'LF', 'HF');
    title('HRV Frequency Spectrum');
    xlabel('Frequency (Hz)'); ylabel('Power');
    xlim([0 0.5]); grid on;
else
    text(0.2, 0.5, 'Not enough RR intervals for HRV spectrum', 'Units', 'normalized');
    title('HRV Spectrum (insufficient data)');
end

end