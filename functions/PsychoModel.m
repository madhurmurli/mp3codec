function [x] = PsychoModel(inputAudioFrame, fs)
%PSYCHOMODEL Summary of this function goes here
%   Detailed explanation goes here

% Create the Window
hannWindow = hanning(MP3config.frameSize);
if size(inputAudioFrame, 1) == 2
    hannWindow = [hannWindow; hannWindow];
end

% Apply the Window
windowedAudioFrame = inputAudioFrame .* hannWindow;

% Take Fourier Transform
fftFrame = fft(windowedAudioFrame, MP3config.fftSize, 2);

% FORCE MONO...
fftFrame = fftFrame(1, :);

% Compute FFT magnitude and apply adjustment
fftFrameMags = MP3config.splBias + 20.*log10(abs(fftFrame));

% Take half of the spectrum
fftFrameMags = fftFrameMags(:, 1:MP3config.fftSize/2);

% Find the Maskers
[isTonalMasker, tonalMaskerMags, noiseMaskerLocsInBark, noiseMaskerMagsPerBark] = findMaskers(fftFrameMags, fs);

% Remove the inaudible Maskers
[isTonalMasker, tonalMaskerMags] = removeMaskers(isTonalMasker, tonalMaskerMags, fs);

end

