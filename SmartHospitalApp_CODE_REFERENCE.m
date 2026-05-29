% =========================================================
% SmartHospitalApp_CODE_REFERENCE.m
% Smart Hospital Patient Monitoring System — App Designer
%
% HOW TO USE:
%   1. Open MATLAB → Apps → App Designer → New App → Blank App
%   2. In Design View, add all components listed below
%   3. In Code View, paste each function into the matching callback
%   4. Save as SmartHospitalApp.mlapp
%
% NOTE: No toolbox required — all signal processing uses base MATLAB only.
% =========================================================

% =========================================================
% COMPONENTS TO ADD IN DESIGN VIEW:
%
%  UIAxes  → Name: RawECGAxes       Label: "ECG Signal"
%  UIAxes  → Name: FilteredAxes     Label: "Mixed vs Filtered"
%  UIAxes  → Name: FFTAxes          Label: "FFT Spectrum"
%  UIAxes  → Name: LaplaceAxes      Label: "Infusion Pump Step Response"
%  UIAxes  → Name: RespAxes         Label: "Respiration"
%  UIAxes  → Name: HRVAxes          Label: "HRV Spectrum"
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
%  Label   → Name: SpO2Label        Text: "SpO2: --"
% =========================================================


% ---------------------------------------------------------
% startupFcn — auto-called when app opens
% ---------------------------------------------------------
function startupFcn(app)
    app.fs       = 500;
    app.duration = 10;

    app.AlertLamp.Color  = [0.2 0.8 0.2];
    app.AlertLabel.Text  = 'System Ready';
    app.StatusLabel.Text = 'Press Run Simulation to begin';

    app.fsSlider.Value     = app.fs;
    app.DurationKnob.Value = app.duration;
end


% ---------------------------------------------------------
% RunButton → ButtonPushedFcn
% ---------------------------------------------------------
function RunButtonPushed(app, event)
    app.fs       = round(app.fsSlider.Value);
    app.duration = round(app.DurationKnob.Value);
    app.StatusLabel.Text = 'Running...';
    drawnow;

    % Member 1: ECG
    [ecg, t] = m1_generate_ecg(app.fs, app.duration);
    cla(app.RawECGAxes);
    plot(app.RawECGAxes, t, ecg, 'b');
    app.RawECGAxes.Title.String  = 'Raw ECG Signal';
    app.RawECGAxes.XLabel.String = 'Time (s)';
    app.RawECGAxes.YLabel.String = 'Amplitude';

    % Member 3: Mix + filter
    mixed = m3_mix_signals(ecg, t);
    clean = m3_butterworth_filter(mixed, app.fs);
    cla(app.FilteredAxes);
    plot(app.FilteredAxes, t, mixed, 'r', t, clean, 'g');
    legend(app.FilteredAxes, 'Mixed (noisy)', 'Filtered');
    app.FilteredAxes.Title.String = 'Mixed vs Filtered Signal';

    % Member 2: FFT
    [f_m, mag_m] = m2_fft_analysis(mixed, app.fs);
    [f_c, mag_c] = m2_fft_analysis(clean, app.fs);
    cla(app.FFTAxes);
    plot(app.FFTAxes, f_m, mag_m, 'r', f_c, mag_c, 'g');
    xlim(app.FFTAxes, [0 50]);
    legend(app.FFTAxes, 'Before filter', 'After filter');
    app.FFTAxes.Title.String = 'FFT Spectrum Comparison';

    % Member 4: Laplace — drug infusion step response
    % Uses Euler integration — NO Control System Toolbox required
    sys_tf = m4_build_tf();
    a = sys_tf.den / sys_tf.den(1);
    b = sys_tf.num / sys_tf.den(1);
    b = [zeros(1, length(a) - length(b)), b];
    dt = 0.05; t_sim = 0:dt:120;
    ord = length(a)-1; w_st = zeros(ord,1);
    y_sim = zeros(size(t_sim));
    for k = 1:length(t_sim)
        w_n = 1.0 - a(2:end)*w_st;
        y_sim(k) = b(2:end)*w_st + b(1)*w_n;
        w_st = [w_n; w_st(1:end-1)];
    end
    cla(app.LaplaceAxes);
    plot(app.LaplaceAxes, t_sim, y_sim, 'b');
    yline(app.LaplaceAxes, 1.0, 'r--');
    app.LaplaceAxes.Title.String  = 'Drug Infusion — Step Response';
    app.LaplaceAxes.XLabel.String = 'Time (s)';
    app.LaplaceAxes.YLabel.String = 'Concentration';

    % Member 5: Respiration
    [resp, ~] = m5_generate_respiration(app.fs, app.duration);
    cla(app.RespAxes);
    plot(app.RespAxes, t, resp, 'm');
    app.RespAxes.Title.String = 'Respiration Signal';
    resp_rate = m5_respiration_rate(resp, app.fs);
    if ~isnan(resp_rate)
        app.RespRateLabel.Text = sprintf('RR: %.0f bpm', resp_rate);
    end

    % Member 6: HRV spectrum
    [rr_int, ~] = m6_extract_rr(ecg, t, app.fs);
    cla(app.HRVAxes);
    if length(rr_int) > 8
        fs_rr = 4;
        t_rr  = 0:1/fs_rr:(length(rr_int)-1)/fs_rr;
        rr_rs = interp1(1:length(rr_int), rr_int, ...
            linspace(1,length(rr_int),length(t_rr)));
        N = length(rr_rs); Y = fft(rr_rs);
        mg = 2*abs(Y(1:floor(N/2)+1))/N;
        fa = fs_rr*(0:floor(N/2))/N;
        plot(app.HRVAxes, fa, mg, 'k');
        xlim(app.HRVAxes, [0 0.5]);
        app.HRVAxes.Title.String = 'HRV Frequency Spectrum';
    end

    % Heart rate from FFT
    cardiac_idx = find(f_c >= 0.5 & f_c <= 4.0);
    if ~isempty(cardiac_idx)
        [~, li] = max(mag_c(cardiac_idx));
        hr = f_c(cardiac_idx(li)) * 60;
        app.HeartRateLabel.Text = sprintf('HR: %.0f bpm', hr);
    end

    % SpO2
    [ppg, ~] = m7_generate_ppg(app.fs, app.duration);
    spo2 = m7_estimate_spo2(ppg);
    app.SpO2Label.Text = sprintf('SpO2: %.1f%%', spo2);

    % Alert logic
    is_arr = m2_detect_arrhythmia(clean, app.fs);
    [sig_alert, alert_msg] = m3_smart_alert(mixed, app.fs);

    if is_arr
        app.AlertLamp.Color = [0.9 0.1 0.1];
        app.AlertLabel.Text = 'ARRHYTHMIA DETECTED';
    elseif sig_alert
        app.AlertLamp.Color = [1.0 0.6 0.0];
        app.AlertLabel.Text = alert_msg;
    else
        app.AlertLamp.Color = [0.2 0.8 0.2];
        app.AlertLabel.Text = 'All Vitals Normal';
    end

    app.StatusLabel.Text = 'Simulation complete';
end


% ---------------------------------------------------------
% ResetButton → ButtonPushedFcn
% ---------------------------------------------------------
function ResetButtonPushed(app, event)
    cla(app.RawECGAxes);
    cla(app.FilteredAxes);
    cla(app.FFTAxes);
    cla(app.LaplaceAxes);
    cla(app.RespAxes);
    cla(app.HRVAxes);

    app.AlertLamp.Color     = [0.2 0.8 0.2];
    app.AlertLabel.Text     = 'System Ready';
    app.StatusLabel.Text    = 'Press Run Simulation to begin';
    app.HeartRateLabel.Text = 'HR: --';
    app.RespRateLabel.Text  = 'RR: --';
    app.SpO2Label.Text      = 'SpO2: --';
end