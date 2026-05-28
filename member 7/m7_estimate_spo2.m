function spo2 = m7_estimate_spo2(ppg)
% Estimate SpO2 (oxygen saturation %) from PPG AC/DC ratio
% Here we simulate the R-value from single PPG using AC/DC components
% =========================================
% AC/DC Components
% =========================================
%DC component = constant tissue, bone, venous blood  (doesn't change)
%AC component = arterial blood pulsing with each beat (changes with heartbeat)
AC = max(ppg) - min(ppg);

DC = mean(ppg);
% Perfusion Index: ratio of pulsatile to non-pulsatile blood flow
PI = (AC / DC) * 100;

% =========================================
% SpO2 Estimation
% =========================================
%The R Ratio
R = AC / (DC + 0.01);

spo2 = 98 - 2*R;

% keep realistic range
spo2 = max(92, min(100, spo2));

fprintf('SpO2 estimate: %.1f%%\n', spo2);

fprintf('Perfusion Index: %.2f%%\n', PI);

% =========================================
% Alert Logic
% =========================================

if spo2 < 90

    fprintf('CRITICAL ALERT: Hypoxemia!\n');

elseif spo2 < 95

    fprintf('WARNING: Low oxygen saturation\n');

else

    fprintf('SpO2 normal\n');

end

end