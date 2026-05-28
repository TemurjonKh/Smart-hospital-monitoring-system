function m2_compare_spectra(raw, filtered, fs)

[f_raw,  m_raw]  = m2_fft_analysis(raw, fs);

[f_filt, m_filt] = m2_fft_analysis(filtered, fs);

figure('Name', 'M2: Fourier Spectra Comparison');

subplot(2,1,1);

plot(f_raw, m_raw, 'b');

xlim([0 50]);

xlabel('Frequency (Hz)');
ylabel('|X(f)|');

title('Spectrum BEFORE Filtering');

subplot(2,1,2);

plot(f_filt, m_filt, 'g');

xlim([0 50]);

xlabel('Frequency (Hz)');
ylabel('|X(f)|');

title('Spectrum AFTER Filtering');

end