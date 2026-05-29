function is_arrhythmia = m2_detect_arrhythmia(signal, fs)

[freqs, mags] = m2_fft_analysis(signal, fs);

% Restrict search to cardiac frequency band (0.5–4 Hz = 30–240 bpm)
% Without this, 60 Hz EMI or harmonics can be mistaken for the heart rate
cardiac_idx = find(freqs >= 0.5 & freqs <= 4.0);

if isempty(cardiac_idx)
    fprintf('Arrhythmia detection skipped: signal too short for frequency resolution.\n');
    is_arrhythmia = false;
    return;
end

[~, local_idx] = max(mags(cardiac_idx));
dominant_freq = freqs(cardiac_idx(local_idx));

normal_low  = 0.8;
normal_high = 2.0;

is_arrhythmia = ...
    (dominant_freq < normal_low || dominant_freq > normal_high);

if is_arrhythmia

    fprintf('ARRHYTHMIA DETECTED: %.2f Hz (%.0f bpm)\n', ...
        dominant_freq, dominant_freq*60);

else

    fprintf('Normal rhythm: %.2f Hz (%.0f bpm)\n', ...
        dominant_freq, dominant_freq*60);

end

end