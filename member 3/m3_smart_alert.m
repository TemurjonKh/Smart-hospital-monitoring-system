function [alert, msg] = m3_smart_alert(signal, fs)

alert = false;

msg = 'All vitals normal';

% Flatline detection
if std(signal) < 0.05

    alert = true;

    msg = 'ALERT: Flatline detected!';

    return;

end

% Abnormal spike detection
threshold = mean(signal) + 5*std(signal);

if any(abs(signal) > threshold)

    alert = true;

    msg = 'ALERT: Abnormal amplitude spike!';

    return;

end

% Noise estimation
clean = m3_butterworth_filter(signal, fs);

noise_ratio = rms(signal - clean) / rms(signal);

if noise_ratio > 0.4

    alert = true;

    msg = sprintf('HIGH NOISE: %.0f%% noise content', ...
        noise_ratio*100);

end

end