function [x] = PsychoModel(inputAudio)
%PSYCHOMODEL Summary of this function goes here
%   Detailed explanation goes here

% Create the Window
hannWindow = hanning(MP3config.frameSize);
if size(inputAudio,1) == 2
    hannWindow = [hannWindow; hannWindow];
end

% Apply the Window
windowedAudio = inputAudio .* hannWindow;

% Take Fourier Transform
fdomain_audio = fft(windowedAudio, MP3config.fftSize, 2);

% Compute magnitude and apply adjustment
adjusted_mag = MP3config.splBias + 20.*log10(abs(fdomain_audio));

% Take half of the mags
adjusted_mag = adjusted_mag(:,1:MP3config.fftSize/2);



end

