function [alert, msg] = m3_smart_alert(signal, fs)
% M3_SMART_ALERT  Smart alert logic for biomedical signal monitoring
% signal = input signal vector (e.g. mixed ECG)
% fs     = sampling frequency in Hz
% Returns: alert (true/false) and msg (description string)
% No toolbox required — rms computed manually as sqrt(mean(x.^2))

    alert = false;
    msg   = 'All vitals normal';

    %% --- Check 1: Flatline detection ---
    % If std is near zero the signal has no variation — patient flatlined
    % or sensor disconnected
    if std(signal) < 0.05
        alert = true;
        msg   = 'ALERT: Flatline detected!';
        return;
    end

%% --- Check 2: Abnormal spike detection ---
% Threshold at mean +/- 8*std so normal ECG R-peaks (which reach ~3.0
% amplitude by design in m1_generate_ecg) do NOT false-trigger.
% Only genuine artifacts such as electrode pops or clipping will exceed
% 8 standard deviations from the mean.
    upper_thresh = mean(signal) + 8 * std(signal);
    lower_thresh = mean(signal) - 8 * std(signal);

    if any(signal > upper_thresh | signal < lower_thresh)
        alert = true;
        msg   = 'ALERT: Abnormal amplitude spike!';
        return;
    end

%% --- Check 3: Noise estimation ---
% Compare raw signal energy to filtered signal energy.
% rms() requires Signal Processing Toolbox so we compute manually:
%   rms(x) = sqrt(mean(x.^2))
    clean      = m3_butterworth_filter(signal, fs, false);   % no plot from alert
    rms_noise  = sqrt(mean((signal - clean).^2));
    rms_signal = sqrt(mean(signal.^2));

    % Guard against silent division by zero
    if rms_signal < 1e-10
        alert = true;
        msg   = 'ALERT: Signal too weak to analyse!';
        return;
    end

    noise_ratio = rms_noise / rms_signal;

    if noise_ratio > 0.4
        alert = true;
        msg   = sprintf('HIGH NOISE: %.0f%% noise content', noise_ratio * 100);
    end

end