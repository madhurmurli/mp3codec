function [isTonalMasker, tonalMaskerMags] = removeMaskers(isTonalMasker, tonalMaskerMags, fs)
%REMOVEMASKERS - Remove the Maskers below the Threshold of Hearing

% Get the Threshold of Hearing...
hearingThreshold = getHearingThreshold(MP3config.fftSize/2, fs);

% For each Tonal Masker...
for i = 1:length(isTonalMasker)
    % If it's not a Tonal Masker, it's magnitude is zero...
    if isTonalMasker(i) == 0
        tonalMaskerMags(i) = 0;
        
    % If it is a Tonal Masker
    else
        % Check if it falls below the Threshold
        if(hearingThreshold(i) > tonalMaskerMags(i))
            tonalMaskerMags(i) = 0;
            isTonalMasker(i) = 0;
        end
    end
end

end

