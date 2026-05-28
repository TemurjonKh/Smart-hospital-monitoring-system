function m2_plot_spectrum(freqs, mags)

    figure('Name', 'FFT Spectrum');

    plot(freqs, mags);

    xlim([0 20]);

    xlabel('Frequency (Hz)');

    ylabel('|X(f)|');

    title('Single-Sided FFT Spectrum');

    grid on;

end