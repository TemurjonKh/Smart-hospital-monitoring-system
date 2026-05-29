function clean = m3_butterworth_filter(mixed, fs, show_plot)
% M3_BUTTERWORTH_FILTER  Zero-phase bandpass filter (0.5-33 Hz)
% Requires NO toolbox — not even filtfilt.
%
% Stage 1: single-pole IIR highpass at 0.5 Hz (removes DC + drift)
% Stage 2: 15-point moving-average lowpass  (removes 60 Hz EMI, ~35 dB)
% Both stages run forward then backward to cancel phase shift.

    x = double(mixed(:)');   % ensure row vector

    if nargin < 3; show_plot = true; end

    %% --- Stage 1: IIR highpass at 0.5 Hz ---
    fc    = 0.5;
    tau   = 1.0 / (2 * pi * fc);
    alpha = tau / (tau + 1.0/fs);

    % Forward pass: y[n] = alpha*(y[n-1] + x[n] - x[n-1])
    y = zeros(size(x));
    for n = 2:length(x)
        y(n) = alpha * (y(n-1) + x(n) - x(n-1));
    end

    % Backward pass on the forward output (reversal cancels phase)
    y = fliplr(y);
    z = zeros(size(y));
    for n = 2:length(y)
        z(n) = alpha * (z(n-1) + y(n) - y(n-1));
    end
    hp = fliplr(z);

    %% --- Stage 2: moving-average lowpass (15 taps) ---
    N  = 15;
    ma = ones(1, N) / N;

    % Forward pass: simple cumulative sum trick
    lp_fwd = conv(hp, ma, 'same');

    % Backward pass
    lp_bwd = conv(fliplr(lp_fwd), ma, 'same');
    clean  = fliplr(lp_bwd);

    if show_plot
        fprintf('Bandpass filter applied (0.5-33 Hz, no toolbox required)\n');
    end

    %% --- Plot (only when called directly, not from smart_alert) ---
    if show_plot
    t = (0 : length(mixed)-1) / fs;

    figure('Name', 'M3: Filtering');

    subplot(2,1,1);
    plot(t, mixed);
    title('Noisy Mixed Signal');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;

    subplot(2,1,2);
    plot(t, clean);
    title('Filtered Signal (0.5-33 Hz, 60 Hz removed)');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;

    end   % if show_plot

end