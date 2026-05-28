function m6_hrv_metrics(rr_intervals)

% =========================================
% Convert RR intervals to milliseconds
% =========================================

rr_ms = rr_intervals * 1000;

% =========================================
% HRV Metrics
% =========================================

sdnn = std(rr_ms);

rmssd = sqrt(mean(diff(rr_ms).^2));

pnn50 = ...
    sum(abs(diff(rr_ms)) > 50) ...
    / length(rr_ms) * 100;

% =========================================
% Display Results
% =========================================

fprintf('\n--- HRV Metrics ---\n');

fprintf('SDNN  : %.2f ms\n', sdnn);

fprintf('RMSSD : %.2f ms\n', rmssd);

fprintf('pNN50 : %.1f %%\n', pnn50);

% =========================================
% Interpretation
% =========================================

if sdnn < 50

    fprintf('HRV ALERT: Low HRV detected\n');

else

    fprintf('HRV within normal range\n');

end

end