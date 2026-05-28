% =========================================================
% SmartHospitalApp_CODE_REFERENCE.m
% Member 5 builds the .mlapp file in App Designer.
% This file contains ALL the callback code to paste in.
%
% HOW TO USE:
%   1. Open MATLAB → Apps → App Designer → New App → Blank App
%   2. In Design View, add components listed at the top of this file
%   3. In Code View, paste each function below into the matching callback
%   4. Save as SmartHospitalApp.mlapp
% =========================================================

% =========================================================
% COMPONENTS TO ADD IN DESIGN VIEW (drag from Component Panel):
%
%  UIAxes  → Name: RawECGAxes      Position: top-left
%  UIAxes  → Name: FilteredAxes    Position: top-right
%  UIAxes  → Name: FFTAxes         Position: mid-left
%  UIAxes  → Name: LaplaceAxes     Position: mid-right
%  UIAxes  → Name: RespAxes        Position: bottom-left
%  UIAxes  → Name: HRVAxes         Position: bottom-right
%
%  Button  → Name: RunButton        Text: "Run Simulation"
%  Button  → Name: ResetButton      Text: "Reset"
%  Slider  → Name: fsSlider         Limits: [100 1000]  Value: 500
%  Knob    → Name: DurationKnob     Limits: [5 30]      Value: 10
%  Lamp    → Name: AlertLamp        Color: [0.2 0.8 0.2]
%  Label   → Name: AlertLabel       Text: "System Ready"
%  Label   → Name: StatusLabel      Text: "Press Run"
%  Label   → Name: HeartRateLabel   Text: "HR: --"
%  Label   → Name: RespRateLabel    Text: "RR: --"
% =========================================================


% ---------------------------------------------------------
% PASTE THIS INTO: startupFcn  (auto-called when app opens)
% ---------------------------------------------------------
function startupFcn(app)
    % Initialize default parameters
    app.fs       = 500;    % default sampling frequency
    app.duration = 10;     % default duration in seconds

    % Set alert lamp to green (normal)
    app.AlertLamp.Color  = [0.2 0.8 0.2];
    app.AlertLabel.Text  = 'System Ready';
    app.StatusLabel.Text = 'Press Run Simulation to begin';

    % Set slider and knob to defaults
    app.fsSlider.Value      = app.fs;
    app.DurationKnob.Value  = app.duration;
end


% ---------------------------------------------------------
% PASTE THIS INTO: RunButton → ButtonPushedFcn callback
% ---------------------------------------------------------
function RunButtonPushed(app, event)
    % Read parameters from UI controls
    app.fs       = round(app.fsSlider.Value);
    app.duration = round(app.DurationKnob.Value);
    app.StatusLabel.Text = 'Running...';
    drawnow;

    % --- Member 1: Generate ECG ---
    [ecg, t] = m1_generate_ecg(app.fs, app.duration);
    plot(app.RawECGAxes, t, ecg, 'b');
    app.RawECGAxes.Title.String  = 'Raw ECG Signal';
    app.RawECGAxes.XLabel.String = 'Time (s)';
    app.RawECGAxes.YLabel.String = 'Amplitude';

    % --- Member 3: Mix signals then filter ---
    mixed = m3_mix_signals(ecg, t);
    clean = m3_butterworth_filter(mixed, app.fs);
    plot(app.FilteredAxes, t, mixed, 'r', t, clean, 'g');
    legend(app.FilteredAxes, 'Mixed (noisy)', 'Filtered');
    app.FilteredAxes.Title.String = 'Mixed vs Filtered Signal';

    % --- Member 2: FFT comparison ---
    [f_m, mag_m] = m2_fft_analysis(mixed, app.fs);
    [f_c, mag_c] = m2_fft_analysis(clean, app.fs);
    plot(app.FFTAxes, f_m, mag_m, 'r', f_c, mag_c, 'g');
    xlim(app.FFTAxes, [0 50]);
    legend(app.FFTAxes, 'Before filter', 'After filter');
    app.FFTAxes.Title.String = 'FFT Spectrum';

    % --- Member 4: Laplace step response ---
    sys = m4_build_tf();
    step(sys, app.LaplaceAxes);
    app.LaplaceAxes.Title.String = 'Step Response - Temp Control';

    % --- Member 5: Respiration ---
    [resp, ~] = m5_generate_respiration(app.fs, app.duration);
    plot(app.RespAxes, t, resp, 'm');
    app.RespAxes.Title.String = 'Respiration Signal';
    resp_rate = m5_respiration_rate(resp, app.fs);
    app.RespRateLabel.Text = sprintf('RR: %.0f bpm', resp_rate);

    % --- Member 6: HRV ---
    m6_full_dashboard(ecg, t, app.fs);

    % --- Compute heart rate for display ---
    [freqs, mags] = m2_fft_analysis(clean, app.fs);
    [~, idx] = max(mags);
    hr = freqs(idx) * 60;
    app.HeartRateLabel.Text = sprintf('HR: %.0f bpm', hr);

    % --- Alerts: arrhythmia + signal quality ---
    is_arr = m2_detect_arrhythmia(clean, app.fs);
    [sig_alert, alert_msg] = m3_smart_alert(mixed, app.fs);

    if is_arr
        app.AlertLamp.Color = [0.9 0.1 0.1];    % red
        app.AlertLabel.Text = 'ARRHYTHMIA DETECTED';
    elseif sig_alert
        app.AlertLamp.Color = [1.0 0.6 0.0];    % orange
        app.AlertLabel.Text = alert_msg;
    else
        app.AlertLamp.Color = [0.2 0.8 0.2];    % green
        app.AlertLabel.Text = 'All Vitals Normal';
    end

    app.StatusLabel.Text = 'Simulation complete';
end


% ---------------------------------------------------------
% PASTE THIS INTO: ResetButton → ButtonPushedFcn callback
% ---------------------------------------------------------
function ResetButtonPushed(app, event)
    % Clear all axes and reset labels to default state
    cla(app.RawECGAxes);
    cla(app.FilteredAxes);
    cla(app.FFTAxes);
    cla(app.LaplaceAxes);
    cla(app.RespAxes);
    cla(app.HRVAxes);

    app.AlertLamp.Color      = [0.2 0.8 0.2];
    app.AlertLabel.Text      = 'System Ready';
    app.StatusLabel.Text     = 'Press Run Simulation to begin';
    app.HeartRateLabel.Text  = 'HR: --';
    app.RespRateLabel.Text   = 'RR: --';
end
