function [freqs, magnitudes] = m2_fft_analysis(signal, fs)
    % Compute and plot the FFT spectrum of a signal
    % signal = input vector (ECG or respiration)
    % fs     = sampling frequency in Hz
    % Returns: frequency axis and magnitude spectrum

    N = length(signal);                      % number of samples
    Y = fft(signal);                         % compute FFT
    magnitudes = abs(Y/N);                   % normalize magnitude
    magnitudes = magnitudes(1:floor(N/2)+1); % single-sided
    magnitudes(2:end-1) = 2*magnitudes(2:end-1); % correct amplitude
    freqs = fs * (0:floor(N/2)) / N;        % frequency axis (Hz)

    % Find dominant frequency (peak in spectrum)
    [~, peak_idx] = max(magnitudes);
    dominant_freq = freqs(peak_idx);
    fprintf('Dominant frequency: %.2f Hz (%.1f bpm)\n', dominant_freq, dominant_freq*60);
end

function is_arrhythmia = m2_detect_arrhythmia(signal, fs)
    % Detect arrhythmia by checking if dominant heart frequency
    % falls outside normal sinus rhythm range (0.8-2.0 Hz = 48-120 bpm)
    % Returns: true if arrhythmia detected, false if normal

    [freqs, mags] = m2_fft_analysis(signal, fs);
    [~, idx] = max(mags);
    dominant_freq = freqs(idx);

    normal_low  = 0.8;   % 48 bpm
    normal_high = 2.0;   % 120 bpm

    is_arrhythmia = (dominant_freq < normal_low || dominant_freq > normal_high);

    if is_arrhythmia
        fprintf('ARRHYTHMIA DETECTED: %.2f Hz (%.0f bpm)\n', dominant_freq, dominant_freq*60);
    else
        fprintf('Normal rhythm: %.2f Hz (%.0f bpm)\n', dominant_freq, dominant_freq*60);
    end
end

function m2_compare_spectra(raw, filtered, fs)
    % Plot spectra side by side: before and after LTI filtering
    % Visually confirms that noise frequencies are removed

    [f_raw,  m_raw]  = m2_fft_analysis(raw,      fs);
    [f_filt, m_filt] = m2_fft_analysis(filtered, fs);

    figure('Name', 'M2: Fourier Spectra Comparison');
    subplot(2,1,1);
    plot(f_raw, m_raw, 'b'); xlim([0 50]);
    title('Spectrum BEFORE Filtering'); xlabel('Frequency (Hz)'); ylabel('|X(f)|');
    subplot(2,1,2);
    plot(f_filt, m_filt, 'g'); xlim([0 50]);
    title('Spectrum AFTER Filtering'); xlabel('Frequency (Hz)'); ylabel('|X(f)|');
end
