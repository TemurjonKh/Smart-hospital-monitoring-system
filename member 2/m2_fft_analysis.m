function [freqs, magnitudes] = m2_fft_analysis(signal, fs)

    N = length(signal);

    Y = fft(signal);

    magnitudes = abs(Y/N);

    magnitudes = magnitudes(1:floor(N/2)+1);

    magnitudes(2:end-1) = 2*magnitudes(2:end-1);

    freqs = fs*(0:floor(N/2))/N;

end