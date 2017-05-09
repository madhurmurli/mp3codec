function [bark_index, bark_mag] = calculateNoiseMaskers(isNoiseMasker, fftFrame, fs)

    % What are these exactly?
    bark_count = zeros(1,length(MP3config.barkBandLimits));
    bark_mag = zeros(1,length(MP3config.barkBandLimits));
    bark_index = ones(1,length(MP3config.barkBandLimits));
    
    % For each FFT Bin...
    for i=1:length(fftFrame)
        % If this Bin was determined to be a Noise Masker...
        if(isNoiseMasker(i) == 1)
            % Get the Bark Band Number for this Bin
            cur_bark = getBarkBandNumber(i * fs/MP3config.fftSize);
            
            % Increase the number of Noise Maskers in the cur_bark Bark Band
            bark_count(cur_bark) = bark_count(cur_bark) + 1;
            
            % Aggregate the Noise Masker magnitudes
            bark_mag(cur_bark) = bark_mag(cur_bark) + 10^(0.1 * fftFrame(i));
            
            % Geometric Mean?
            bark_index(cur_bark) = bark_index(cur_bark) * i;
        end
    end
    
    % dB the Bark Magnitudes
    bark_mag = 10 * log10(bark_mag);
    
    % For each Bark Band...
    for i = 1:length(MP3config.barkBandLimits)
        % Take the n-th root to get the Bark Band Index.. ?
        bark_index(i) = round(nthroot(bark_index(i), bark_count(i)));
    end
    
end