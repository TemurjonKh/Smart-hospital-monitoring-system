function [ecg, t] = m1_generate_ecg(fs, duration)

% Generate synthetic ECG signal

t = 0 : 1/fs : duration - 1/fs;

f_heart = 1.2;

ecg = 1.0 * sin(2*pi*f_heart*t) ...
    + 0.5 * sin(2*pi*2*f_heart*t) ...
    + 0.3 * sin(2*pi*3*f_heart*t) ...
    + 0.1 * randn(size(t));

% Add R-peaks
spike_times = 0.4 : 1/f_heart : duration;

for i = 1:length(spike_times)

    idx = round(spike_times(i) * fs);

    if idx > 0 && idx <= length(ecg)
        ecg(idx) = ecg(idx) + 3.0;
    end

end

end