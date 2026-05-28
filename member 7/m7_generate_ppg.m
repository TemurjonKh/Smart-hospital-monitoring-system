function [ppg, t] = m7_generate_ppg(fs, duration)

    % =========================================
    % Synthetic PPG Signal
    % =========================================

    t = 0 : 1/fs : duration - 1/fs;

    f_pulse = 1.2;    % ~72 bpm

    % PPG waveform
    % Any real-world signal can be broken into a sum of sine waves at different frequencies
    ppg = 1.0 * sin(2*pi*f_pulse*t) ...
        + 0.3 * sin(2*pi*2*f_pulse*t + 0.8) ...
        + 0.1 * sin(2*pi*3*f_pulse*t) ...
        + 0.04 * randn(size(t));

    % Normalize [0, 1]
    ppg = (ppg - min(ppg)) ...
        / (max(ppg) - min(ppg));

    fprintf('PPG signal generated: %.0f bpm\n', ...
            f_pulse*60);

end