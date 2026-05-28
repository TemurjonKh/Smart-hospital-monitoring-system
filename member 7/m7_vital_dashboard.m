function m7_vital_dashboard(ppg, t, fs)
    % =========================================
    % Vital Estimates
    % =========================================
    spo2 = m7_estimate_spo2(ppg);
    [sys, dia, map_val] = ...
        m7_estimate_blood_pressure(ppg, fs);

    % =========================================
    % Simulated Trends
    % =========================================
    t_trend = linspace(0, 30, 300);
    spo2_trend = ...
        98 - 4*sin(2*pi*0.05*t_trend) ...
        + 0.3*randn(size(t_trend));
    spo2_trend = ...
        max(88, min(100, spo2_trend));
    bp_sys_trend = ...
        sys + 5*sin(2*pi*0.03*t_trend) ...
        + 1.5*randn(size(t_trend));
    bp_dia_trend = ...
        dia + 3*sin(2*pi*0.03*t_trend) ...
        + 0.8*randn(size(t_trend));
    % =========================================
    % Dashboard
    % =========================================

    figure('Name', ...
        'M7: Blood Pressure & SpO2 Dashboard', ...
        'Position', [100 100 1000 700]);
    % =========================================
    % PPG Waveform
    % =========================================
    subplot(3,2,[1 2]);
    plot(t, ppg, 'LineWidth', 1.2);
    title('PPG Waveform');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    % =========================================
    % SpO2 Trend
    % =========================================

    subplot(3,2,3);
    plot(t_trend, spo2_trend, 'b');
    hold on;
    yline(95, 'r--', 'Low');
    yline(90, 'r', 'Critical');
    hold off;
    ylim([85 100]);
    title(sprintf('SpO2 Trend: %.1f%%', spo2));
    xlabel('Time (s)');
    ylabel('SpO2 (%)');
    grid on;

    % =========================================
    % Blood Pressure Trend
    % =========================================

    subplot(3,2,4);
    plot(t_trend, bp_sys_trend, 'r');
    hold on;

    plot(t_trend, bp_dia_trend, 'b');
    yline(140, 'r--');
    yline(90, 'b--');
    hold off;

    legend('Systolic', 'Diastolic');
    title(sprintf('BP: %.0f / %.0f mmHg', ...
          sys, dia));
    xlabel('Time (s)');
    ylabel('Pressure (mmHg)');
    grid on;

    % =========================================
    % Frequency Spectrum
    % =========================================

    subplot(3,2,5);

    N = length(ppg);

    Y = fft(ppg);

    mags = 2*abs(Y(1:floor(N/2)+1))/N;

    freqs = fs*(0:floor(N/2))/N;

    plot(freqs, mags, 'k');

    xlim([0 5]);

    title('PPG Frequency Spectrum');

    xlabel('Frequency (Hz)');

    ylabel('|PPG(f)|');

    grid on;

    % =========================================
    % Text Summary
    % =========================================

    subplot(3,2,6);

    axis off;

    text(0.1, 0.9, ...
        'VITAL SIGNS SUMMARY', ...
        'FontWeight', 'bold', ...
        'FontSize', 11);

    text(0.1, 0.72, ...
        sprintf('SpO2     : %.1f %%', spo2));

    text(0.1, 0.56, ...
        sprintf('Systolic : %.0f mmHg', sys));

    text(0.1, 0.40, ...
        sprintf('Diastolic: %.0f mmHg', dia));

    text(0.1, 0.24, ...
        sprintf('MAP      : %.1f mmHg', map_val));

    text(0.1, 0.08, ...
        'Status: Monitoring active');

end