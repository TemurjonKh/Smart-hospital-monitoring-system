function mixed = m3_mix_signals(ecg, t)
    % Combine ECG with simulated respiration and temperature drift
    % This models a real hospital sensor fusion scenario

    % Respiration signal ~0.25 Hz (15 breaths/min)
    respiration = 0.4 * sin(2*pi*0.25*t);

    % Slow temperature drift (very low frequency baseline wander)
    temp_drift = 0.2 * sin(2*pi*0.02*t);

    % High-frequency EMI noise (60 Hz power line interference)
    emi_noise = 0.15 * sin(2*pi*60*t);

    % Mix all signals together — realistic hospital scenario
    mixed = ecg + respiration + temp_drift + emi_noise;

    fprintf('Mixed signal: ECG + respiration + drift + 60Hz noise\n');
end

function clean = m3_butterworth_filter(mixed, fs)
    % Apply 4th-order Butterworth bandpass filter to denoise
    % Passband: 0.5-40 Hz (retains ECG, removes drift and EMI)

    low_cut  = 0.5;   % Hz — removes baseline wander
    high_cut = 40;    % Hz — removes 60Hz EMI noise
    order    = 4;     % filter order

    % Design Butterworth filter coefficients
    [b, a] = butter(order, [low_cut high_cut] / (fs/2), 'bandpass');

    % Apply zero-phase filtering (avoids phase distortion)
    clean = filtfilt(b, a, mixed);

    fprintf('Butterworth filter applied: %.1f-%.1f Hz bandpass\n', low_cut, high_cut);
end

function [alert, msg] = m3_smart_alert(signal, fs)
    % Smart decision logic: analyze signal and trigger alerts
    % Checks: noise level, abnormal amplitude, flatline detection

    alert = false;
    msg   = 'All vitals normal';

    % Check 1: Flatline (signal std dev too low)
    if std(signal) < 0.05
        alert = true;  msg = 'ALERT: Flatline detected!';  return;
    end

    % Check 2: Extreme amplitude spike (> 5 standard deviations)
    threshold = mean(signal) + 5*std(signal);
    if any(abs(signal) > threshold)
        alert = true;  msg = 'ALERT: Abnormal amplitude spike!';  return;
    end

    % Check 3: High noise — compare raw vs filtered energy ratio
    clean = m3_butterworth_filter(signal, fs);
    noise_ratio = rms(signal - clean) / rms(signal);
    if noise_ratio > 0.4
        alert = true;  msg = sprintf('HIGH NOISE: %.0f%% noise content', noise_ratio*100);
    end
end
