function m6_full_dashboard(ecg, t, fs)

    % =========================================
    % Extract RR intervals
    % =========================================

    [rr_int, rr_t] = m6_extract_rr(ecg, t, fs);

    % =========================================
    % Dashboard Figure
    % =========================================

    figure('Name', 'M6: HRV Dashboard', ...
           'Position', [100 100 1000 700]);

    % =========================================
    % ECG Signal
    % =========================================

    subplot(3,2,[1 2]);

    plot(t, ecg, 'b');

    title('ECG Signal');

    xlabel('Time (s)');

    ylabel('Amplitude');

    grid on;

    % =========================================
    % RR Tachogram
    % =========================================

    subplot(3,2,3);

    plot(rr_t, rr_int*1000, 'ro-');

    yline(mean(rr_int)*1000, 'b--', 'Mean');

    title('RR Interval Tachogram');

    xlabel('Time (s)');

    ylabel('RR Interval (ms)');

    grid on;

    % =========================================
    % Histogram
    % =========================================

    subplot(3,2,4);

    histogram(rr_int*1000, 15);

    title('RR Interval Histogram');

    xlabel('RR Interval (ms)');

    ylabel('Count');

    grid on;

    % =========================================
    % HRV Frequency Spectrum
    % =========================================

    subplot(3,2,[5 6]);

    if length(rr_int) > 8

        fs_rr = 4;

        t_rr = 0 : 1/fs_rr : (length(rr_int)-1)/fs_rr;

        rr_resampled = interp1( ...
            1:length(rr_int), ...
            rr_int, ...
            linspace(1, length(rr_int), length(t_rr)));

        N = length(rr_resampled);

        Y = fft(rr_resampled);

        mags = 2*abs(Y(1:floor(N/2)+1))/N;

        f_ax = fs_rr*(0:floor(N/2))/N;

        plot(f_ax, mags, 'k');

        hold on;

        % LF Band
        patch([0.04 0.15 0.15 0.04], ...
              [0 0 max(mags) max(mags)], ...
              'b', ...
              'FaceAlpha', 0.15, ...
              'EdgeColor', 'none');

        % HF Band
        patch([0.15 0.4 0.4 0.15], ...
              [0 0 max(mags) max(mags)], ...
              'r', ...
              'FaceAlpha', 0.15, ...
              'EdgeColor', 'none');

        hold off;

        title('HRV Frequency Spectrum');

        xlabel('Frequency (Hz)');

        ylabel('Power');

        legend('Spectrum', 'LF', 'HF');

        xlim([0 0.5]);

        grid on;

    end

end