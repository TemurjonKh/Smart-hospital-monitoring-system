function [sys_bp, dia_bp, map] = ...
         m7_estimate_blood_pressure(ppg, fs)

    % =========================================
    % Simple Peak Detection 
    % =========================================

    min_dist = round(0.4 * fs);
    threshold = mean(ppg) + 0.5 * std(ppg);
    peak_locs = [];
    trough_locs = [];
    % Detect peaks/troughs
    for i = 2:length(ppg)-1
        % Peaks
        if ppg(i) > threshold && ...
           ppg(i) > ppg(i-1) && ...
           ppg(i) > ppg(i+1)
            if isempty(peak_locs) || ...
               (i - peak_locs(end)) > min_dist
                peak_locs(end+1) = i;
            end
        end
        % Troughs
        if ppg(i) < ppg(i-1) && ...
           ppg(i) < ppg(i+1)
            if isempty(trough_locs) || ...
               (i - trough_locs(end)) > min_dist
                trough_locs(end+1) = i;
            end
        end
    end

    % =========================================
    % Safety fallback
    % =========================================

    if isempty(peak_locs) || isempty(trough_locs)
        sys_bp = 120;
        dia_bp = 80;
        map = 93.3;
        fprintf('Default BP values used\n');
        return;
    end

    % =========================================
    % BP Estimation
    % =========================================

    amp = mean(ppg(peak_locs)) ...
        - mean(ppg(trough_locs));

    sys_bp = 90 + amp * 40;
    dia_bp = 60 + amp * 20;
    map = dia_bp + ...
         (1/3) * (sys_bp - dia_bp);
    fprintf('Blood Pressure: %.0f / %.0f mmHg\n', ...
            sys_bp, dia_bp);
    fprintf('MAP: %.1f mmHg\n', map);

    % =========================================
    % Classification
    % =========================================

    if sys_bp > 180 || dia_bp > 120
        fprintf('CRITICAL: Hypertensive Crisis!\n');
    elseif sys_bp > 140 || dia_bp > 90
        fprintf('ALERT: Stage 2 Hypertension\n');
    elseif sys_bp > 130 || dia_bp > 80
        fprintf('WARNING: Stage 1 Hypertension\n');
    elseif sys_bp < 90
        fprintf('ALERT: Hypotension\n');
    else
        fprintf('Blood pressure normal\n');
    end
end