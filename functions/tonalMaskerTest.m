function [isTonal, isNoiseMaskerOut] = tonalMaskerTest(fftFrame, j, isNoiseMasker)
% Determine if a bin is a Tonal Masker

% Assume that it is Tonal and then try to prove that it's not...
isTonal=1;

% Local Maxima
upLim=0;
downLim=0;

% Compare the j-th bin with the previous and next bins
if(fftFrame(1,j) > fftFrame(1,j-1) && fftFrame(1,j) > fftFrame(1,j+1))
    % Figure out the BW Limits based on the FFT Bin number
    if(j>2 && j<63) 
        upLim=2;
        downLim=2;
    elseif(j>=63 && j<127)
        downLim=2;
        upLim=3;
    elseif(j>=127 && j<=256)
        downLim=2;
        upLim=6;
    end
    
    % Define loop indexes
    startInd = j-downLim;
    endInd = j+upLim;
  
    % Loop over the local area
    for i = startInd:endInd
        % If the j-th bin is not a local maxima...
        if(fftFrame(i) > fftFrame(j))
            % It's not a Tonal Masker
            isTonal = 0;
            
        % If the j-th bin is a local maxima...
        else
            % Set the i-th bin as a Noise Masker
            isNoiseMasker(1,i)=0;
        end
    end 

else
    isTonal = 0;

end

isNoiseMaskerOut = isNoiseMasker;

end