function [ecg, t] = m1_generate_ecg(fs, duration)
    % Generate a synthetic ECG signal as sum of sinusoids + noise
    % fs       = sampling frequency (Hz), e.g. 500
    % duration = signal length in seconds, e.g. 5
    % Returns: ecg signal vector and time vector t

    t = 0 : 1/fs : duration - 1/fs;          % time vector
    f_heart = 1.2;                            % ~72 bpm fundamental

    % Superposition of harmonics to mimic ECG waveform shape
    ecg = 1.0 * sin(2*pi*f_heart*t) ...      % fundamental
        + 0.5 * sin(2*pi*2*f_heart*t) ...    % 2nd harmonic
        + 0.3 * sin(2*pi*3*f_heart*t) ...    % 3rd harmonic
        + 0.1 * randn(size(t));              % Gaussian noise

    % Add a simulated QRS spike at t = 0.4s intervals
    spike_times = 0.4 : 1/f_heart : duration;
    for i = 1:length(spike_times)
        idx = round(spike_times(i) * fs);
        if idx > 0 && idx <= length(ecg)
            ecg(idx) = ecg(idx) + 3.0;       % R-peak spike
        end
    end
end

function m1_lti_demo(ecg, t, fs)
    % Demonstrate LTI system operations on the ECG signal
    % Shows: impulse response, convolution, shifting, scaling

    % --- 1. Impulse Response of a simple moving-average LTI system ---
    window = 5;                              % 5-sample moving average
    h = ones(1, window) / window;           % impulse response h[n]

    % --- 2. Convolution: pass ECG through the LTI filter ---
    ecg_filtered = conv(ecg, h, 'same');     % 'same' keeps original length

    % --- 3. Time-shifting: delay signal by 0.2 seconds ---
    shift_samples = round(0.2 * fs);
    ecg_shifted = [zeros(1, shift_samples), ecg(1:end-shift_samples)];

    % --- 4. Scaling: amplify signal by factor 1.5 ---
    ecg_scaled = 1.5 * ecg;

    % --- Plot all operations ---
    figure('Name', 'M1: LTI Time-Domain Operations');
    subplot(4,1,1); plot(t, ecg);  title('Original ECG'); xlabel('Time (s)');
    subplot(4,1,2); stem(h);       title('Impulse Response h[n]');
    subplot(4,1,3); plot(t, ecg_filtered); title('After Convolution (Moving Avg)');
    subplot(4,1,4); plot(t, ecg_shifted, 'r', t, ecg_scaled, 'b');
    title('Shifted (red) vs Scaled (blue)'); legend('Shifted', 'Scaled');
end
