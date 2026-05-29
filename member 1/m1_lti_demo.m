function m1_lti_demo(ecg, t, fs, animate)
% M1_LTI_DEMO  LTI system time-domain operations on ECG signal
%
% SYLLABUS LINK (Weeks 1-4):
%   Demonstrates the four core LTI properties on a real ECG signal:
%   1. Impulse response  — the system's reaction to a single spike
%   2. Convolution       — filtering by passing ECG through h[n]
%   3. Time shifting     — delaying the signal by 0.2 seconds
%   4. Scaling           — amplifying by factor 1.5
%   5. Superposition     — y = y1 + y2 (linearity property)
%
% animate = optional, default false (avoids blocking run_all.m)
% No toolbox required.

if nargin < 4; animate = false; end

%% LTI operations
window        = 5;
h             = ones(1, window) / window;       % impulse response
ecg_filtered  = conv(ecg, h, 'same');           % convolution

shift_samples = round(0.2 * fs);
ecg_shifted   = [zeros(1, shift_samples), ecg(1:end - shift_samples)];

ecg_scaled    = 1.5 * ecg;

%% Superposition: y = signal1 + signal2
% Decompose ECG into two sub-signals and show that processing the sum
% equals the sum of the processed signals (linearity property).
f_heart  = 1.2;
signal1  = sin(2*pi*f_heart*t);              % fundamental harmonic
signal2  = 0.5*sin(2*pi*2*f_heart*t);        % second harmonic
y_sum    = signal1 + signal2;                 % superposition
y1_conv  = conv(signal1, h, 'same');          % filter each separately
y2_conv  = conv(signal2, h, 'same');
y_sep    = y1_conv + y2_conv;                 % add filtered outputs
y_direct = conv(y_sum, h, 'same');            % filter the sum directly
% y_sep and y_direct should be identical — proving LTI superposition

%% Figure
figure('Name', 'M1: LTI Time-Domain Operations');

subplot(5,1,1);
if animate
    el = animatedline('Color','b');
    xlim([0 max(t)]); ylim([min(ecg)-1 max(ecg)+1]);
    xlabel('Time (s)'); ylabel('Amplitude'); grid on;
    for k = 1:5:length(t)
        addpoints(el, t(k), ecg(k)); drawnow; pause(0.003);
    end
    title('Original ECG');
else
    plot(t, ecg, 'b');
    title('Original ECG (sum of harmonics + R-peaks)');
    xlabel('Time (s)'); ylabel('Amplitude'); grid on;
end

subplot(5,1,2);
stem(h, 'filled');
title('Impulse Response h[n] — 5-point Moving Average');
xlabel('Sample index'); ylabel('h[n]');

subplot(5,1,3);
plot(t, ecg_filtered, 'g');
title('After Convolution with h[n] — Smoothed ECG');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(5,1,4);
plot(t, ecg_shifted, 'r'); hold on;
plot(t, ecg_scaled,  'b'); hold off;
legend('Shifted 0.2s', 'Scaled x1.5', 'Location','northeast');
title('Time Shifting vs Amplitude Scaling');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(5,1,5);
plot(t, y_direct, 'b', 'LineWidth', 1.5); hold on;
plot(t, y_sep, 'r--', 'LineWidth', 1);   hold off;
legend('Filter(y1+y2) — direct', 'Filter(y1)+Filter(y2) — separate', ...
       'Location','northeast');
title('Superposition: T\{x_1+x_2\} = T\{x_1\} + T\{x_2\} (lines must overlap)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% Print proof of superposition
max_diff = max(abs(y_direct - y_sep));
fprintf('Superposition verification: max difference = %.2e (should be ~0)\n', max_diff);
if max_diff < 1e-10
    fprintf('LTI superposition CONFIRMED\n');
end

end