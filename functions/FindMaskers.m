function [isTonalMasker, tonalMaskerMags, noiseMaskerLocsInBark, noiseMaskerMagsPerBark] = FindMaskers(fftFrame, fs)
%FINDMASKERS - Picks Tonal and Noise Maskers in a given frame
%
%   Detailed explanation goes here

% Compute tonal flags
isTonalFlags = zeros(size(fftFrame));
tonalMaskerMags = zeros(size(fftFrame));

% Assume everything is a Noise Masker
isNoiseMasker = ones(size(fftFrame));

% Loop over the FFT Bins and check for local maxima
for j = 2:length(fftFrame)-6
    % Is this bin a tonal masker or a noise masker?
    [isTonalFlags(j), isNoiseMasker] = tonalMaskerTest(fftFrame, j, isNoiseMasker);

    % If it's a Tonal Flag...
    if(isTonalFlags(j) == 1)
        t_mag = 0;
        for k = -1:1:1
            t_mag = t_mag + 10^(0.1 * fftFrame(j+k));
        end
        
        tonalMaskerMags(j) = 10 * log10(t_mag);
    end
end

% Calculate Noise Maskers
[noiseMaskerLocsInBark, noiseMaskerMagsPerBark] = calculateNoiseMaskers(isNoiseMasker, fftFrame, fs);

% Outputs...
isTonalMasker = ~isNoiseMasker;

end

