function m1_lti_demo(ecg, t, fs)

% Moving average filter
window = 5;

h = ones(1, window) / window;

% Convolution
ecg_filtered = conv(ecg, h, 'same');

% Time shift
shift_samples = round(0.2 * fs);

ecg_shifted = [zeros(1, shift_samples), ...
    ecg(1:end-shift_samples)];

% Scaling
ecg_scaled = 1.5 * ecg;

% Plotting
figure('Name', 'M1: LTI Operations');

subplot(4,1,1);

ecg_live = animatedline('Color','b');

xlim([0 max(t)]);
ylim([min(ecg)-1 max(ecg)+1]);

title('Live ECG Monitor');

xlabel('Time (s)');
ylabel('Amplitude');

grid on;

for k = 1:5:length(t)
    addpoints(ecg_live, t(k), ecg(k));
    drawnow;
    pause(0.003);
end
title('Original ECG');

subplot(4,1,2);
stem(h);
title('Impulse Response');

subplot(4,1,3);
plot(t, ecg_filtered);
title('Filtered ECG');

subplot(4,1,4);
plot(t, ecg_shifted, 'r');
hold on;
plot(t, ecg_scaled, 'b');
legend('Shifted', 'Scaled');

end