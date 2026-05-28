function clean = m3_butterworth_filter(mixed, fs)

    % Simple moving average filter
    % Toolbox-free replacement

    window = 15;

    h = ones(1, window) / window;

    clean = conv(mixed, h, 'same');

    fprintf('Moving-average filter applied\n');

    % Plot comparison
    t = (0:length(mixed)-1) / fs;

    figure('Name', 'M3: Filtering');

        subplot(2,1,1);
    plot(t, mixed);
    title('Noisy Signal');

    xlabel('Time (s)');
    ylabel('Amplitude');

    subplot(2,1,2);
    plot(t, clean);

    title('Filtered Signal');

    xlabel('Time (s)');
    ylabel('Amplitude');

end