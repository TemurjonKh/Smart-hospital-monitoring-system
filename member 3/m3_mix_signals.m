function mixed = m3_mix_signals(ecg, t)

% Respiration signal
respiration = 0.4 * sin(2*pi*0.25*t);

% Baseline drift
temp_drift = 0.2 * sin(2*pi*0.02*t);

% 60 Hz EMI noise
emi_noise = 0.15 * sin(2*pi*60*t);

% Mixed signal
mixed = ecg + respiration + temp_drift + emi_noise;

fprintf('Mixed signal created\n');

% Plot
figure('Name', 'M3: Mixed Signal');

plot(t, mixed);

xlabel('Time (s)');
ylabel('Amplitude');

title('Mixed Biomedical Signal');

grid on;

end