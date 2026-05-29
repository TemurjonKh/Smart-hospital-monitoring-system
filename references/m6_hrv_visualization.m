function [rr_intervals, rr_times] = m6_extract_rr(ecg, t, fs)
    % Extract RR intervals from ECG signal by detecting R-peaks
    % RR interval = time between consecutive heartbeats
    % Used in Heart Rate Variability (HRV) analysis
    % ecg = ECG signal vector
    % t   = time vector
    % fs  = sampling frequency

    % Find R-peaks using simple threshold + minimum distance method
    threshold = mean(ecg) + 1.5 * std(ecg);  % adaptive threshold
    min_dist  = round(0.4 * fs);              % min 0.4s between beats

    % Detect peaks above threshold
    [~, peak_locs] = findpeaks(ecg, ...
        'MinPeakHeight',    threshold, ...
        'MinPeakDistance',  min_dist);

    % Calculate RR intervals in seconds
    rr_intervals = diff(t(peak_locs));        % time between R-peaks
    rr_times     = t(peak_locs(1:end-1));     % time axis for RR plot

    fprintf('R-peaks detected: %d\n', length(peak_locs));
    fprintf('Mean RR interval: %.3f s (%.0f bpm)\n', ...
        mean(rr_intervals), 60/mean(rr_intervals));
end

function m6_hrv_metrics(rr_intervals)
    % Calculate standard HRV metrics from RR interval series
    % SDNN   = standard deviation of RR intervals (ms) — overall HRV
    % RMSSD  = root mean square of successive differences — short-term HRV
    % pNN50  = percentage of successive differences > 50ms

    rr_ms = rr_intervals * 1000;              % convert to milliseconds

    sdnn  = std(rr_ms);                       % SDNN
    rmssd = sqrt(mean(diff(rr_ms).^2));       % RMSSD
    pnn50 = sum(abs(diff(rr_ms)) > 50) / length(rr_ms) * 100; % pNN50

    fprintf('\n--- HRV Metrics ---\n');
    fprintf('SDNN  : %.2f ms  (Normal > 50ms)\n', sdnn);
    fprintf('RMSSD : %.2f ms  (Normal > 20ms)\n', rmssd);
    fprintf('pNN50 : %.1f %%  (Normal > 3%%)\n',  pnn50);

    % Basic HRV interpretation
    if sdnn < 50
        fprintf('HRV ALERT: Low SDNN — possible cardiac stress\n');
    else
        fprintf('HRV: Normal range\n');
    end
end

function m6_full_dashboard(ecg, t, fs)
    % Produce a comprehensive visualization dashboard for the hospital monitor
    % Shows: ECG, RR intervals, HRV spectrum, statistical summary

    [rr_int, rr_t] = m6_extract_rr(ecg, t, fs);

    figure('Name', 'M6: HRV & Visualization Dashboard', 'Position', [100 100 1000 700]);

    % Panel 1: Full ECG signal
    subplot(3,2,[1 2]);
    plot(t, ecg, 'b', 'LineWidth', 0.8);
    title('Full ECG Signal with R-peaks');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;

    % Panel 2: RR interval tachogram
    subplot(3,2,3);
    plot(rr_t, rr_int*1000, 'ro-', 'LineWidth', 1.2);
    title('RR Interval Tachogram');
    xlabel('Time (s)'); ylabel('RR Interval (ms)');
    yline(mean(rr_int)*1000, 'b--', 'Mean');
    grid on;

    % Panel 3: RR interval histogram
    subplot(3,2,4);
    histogram(rr_int*1000, 15, 'FaceColor', 'cyan', 'EdgeColor', 'k');
    title('RR Interval Distribution');
    xlabel('RR Interval (ms)'); ylabel('Count');
    grid on;

    % Panel 4: FFT of RR intervals (HRV frequency bands)
    subplot(3,2,[5 6]);
    if length(rr_int) > 8
        fs_rr = 4;                            % resample RR to 4 Hz
        t_rr  = 0 : 1/fs_rr : (length(rr_int)-1)/fs_rr;
        rr_resampled = interp1(1:length(rr_int), rr_int, ...
            linspace(1, length(rr_int), length(t_rr)));
        N = length(rr_resampled);
        Y = fft(rr_resampled);
        mags = 2*abs(Y(1:floor(N/2)+1))/N;
        f_ax = fs_rr*(0:floor(N/2))/N;
        plot(f_ax, mags, 'k', 'LineWidth', 1);
        % Mark HRV frequency bands
        patch([0.04 0.15 0.15 0.04],[0 0 max(mags) max(mags)],...
            'b','FaceAlpha',0.15,'EdgeColor','none');  % LF band
        patch([0.15 0.4 0.4 0.15],[0 0 max(mags) max(mags)],...
            'r','FaceAlpha',0.15,'EdgeColor','none');  % HF band
        legend('HRV Spectrum','LF band (0.04-0.15Hz)','HF band (0.15-0.4Hz)');
        title('HRV Frequency Spectrum (LF/HF bands)');
        xlabel('Frequency (Hz)'); ylabel('Power');
        xlim([0 0.5]); grid on;
    end
end
