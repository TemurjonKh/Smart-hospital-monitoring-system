function is_arrhythmia = m2_detect_arrhythmia(signal, fs)

[freqs, mags] = m2_fft_analysis(signal, fs);

[~, idx] = max(mags);

dominant_freq = freqs(idx);

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