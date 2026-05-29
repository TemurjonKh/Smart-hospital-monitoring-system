function [resp, t] = m5_generate_respiration(fs, duration)
    % Generate a synthetic respiration signal
    % Normal adult: 12-20 breaths/min = 0.2-0.33 Hz
    % fs       = sampling frequency (Hz)
    % duration = length in seconds
    % Returns: respiration signal and time vector

    t = 0 : 1/fs : duration - 1/fs;
    f_resp = 0.25;                           % 15 breaths/min

    % Respiration = smooth sinusoid + small noise + slow drift
    resp = 1.2 * sin(2*pi*f_resp*t) ...     % main breathing cycle
         + 0.2 * sin(2*pi*2*f_resp*t) ...   % 2nd harmonic (non-ideal breath shape)
         + 0.05 * randn(size(t)) ...         % sensor noise
         + 0.1 * sin(2*pi*0.005*t);         % very slow baseline drift

    fprintf('Respiration signal generated: %.0f breaths/min\n', f_resp*60);
end

function rate = m5_respiration_rate(resp, fs)
    % Extract respiration rate from signal using FFT peak detection
    % Returns: respiration rate in breaths per minute

    N = length(resp);
    Y = fft(resp);
    mags = abs(Y/N);
    mags = mags(1:floor(N/2)+1);
    mags(2:end-1) = 2 * mags(2:end-1);
    freqs = fs * (0:floor(N/2)) / N;

    % Search only in respiratory range: 0.1-0.6 Hz (6-36 bpm)
    resp_range = freqs >= 0.1 & freqs <= 0.6;
    [~, idx] = max(mags .* resp_range);     % peak within resp range only
    rate = freqs(idx) * 60;                 % convert Hz to bpm

    fprintf('Measured respiration rate: %.1f breaths/min\n', rate);

    % Alert if out of normal range
    if rate < 12 || rate > 20
        fprintf('ALERT: Abnormal respiration rate! (Normal: 12-20 bpm)\n');
    else
        fprintf('Respiration rate normal.\n');
    end
end

function m5_air_quality_dashboard(t, fs)
    % Simulate and plot air quality signals: CO2 and temperature
    % CO2 normal range: 400-1000 ppm in hospital room
    % Temperature normal range: 20-24 degrees C

    % Simulate CO2 level rising and falling with patient breathing
    co2 = 600 + 100*sin(2*pi*0.002*t) + 20*randn(size(t));

    % Simulate room temperature with slow variation
    room_temp = 22 + 0.5*sin(2*pi*0.001*t) + 0.1*randn(size(t));

    % Smart thresholds
    co2_alert   = any(co2 > 1000);
    temp_alert  = any(room_temp > 24 | room_temp < 20);

    figure('Name', 'M5: Air Quality Dashboard');
    subplot(2,1,1);
    plot(t, co2, 'b'); hold on;
    yline(1000, 'r--', 'CO2 Limit'); hold off;
    title('Room CO2 Level (ppm)'); xlabel('Time (s)'); ylabel('ppm');
    if co2_alert; title('Room CO2 Level (ppm) — ALERT: HIGH CO2'); end

    subplot(2,1,2);
    plot(t, room_temp, 'm'); hold on;
    yline(24, 'r--', 'Upper Limit');
    yline(20, 'b--', 'Lower Limit'); hold off;
    title('Room Temperature (C)'); xlabel('Time (s)'); ylabel('Degrees C');
    if temp_alert; title('Room Temperature — ALERT: OUT OF RANGE'); end
end
