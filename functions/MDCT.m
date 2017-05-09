function F = MDCT(S)
%MDCT Summary of this function goes here
%   Detailed explanation goes here


% Load the MDCT Windows -- used for Window Switching
persistent longWindow;
persistent startWindow;
persistent stopWindow;
persistent shortWindows;
if isempty(longWindow) || isempty(startWindow) || isempty(stopWindow) || isempty(shortWindows)
    windows = load('resources/dctWindows', 'dctWindows');
    windows = windows.dctWindows;
    
    longWindow = windows.long;
    startWindow = windows.short;
    stopWindow = windows.stop;
    shortWindows = windows.short;
end


% Frequency Inversion Correction
for gr = 1
    
    % Compensate for inversion in the analysis filter bank
    % Inversion is applied only to the odd time samples of the odd subbands
    band = 2:2:32;
    time_index = 2:2:18;
    S(ch, gr, band, time_index) = -S(ch, gr, band, time_index);

end


% -------------------------------
% Do the MDCT
persistent S_prev;

s = size(S);
s(end) = s(end)/2;
mdctOutput = zeros(s);

mdctInput = zeros(1, 36);

% For each granual...
for gr = 1:size(S,2)
    
    % For each channel...
    for ch = 1:size(S,1)
        
        % For each band...
        for band = 1:size(S,3)
        
            % Build the input to the DCT
            if gr == 1
                if isempty(S_prev)
                    mdctInput(1:18) = zeros(1,18);
                else
                    mdctInput(1:18) = squeeze(S_prev(ch, 2, band, 19:36));
                end
                mdctInput(19:36) = squeeze(S(ch, gr, band, 1:18));
            else
                mdctInput(1:18) = squeeze(S(ch, gr-1, band, 1:18));
                mdctInput(19:36) = squeeze(S(ch, gr, band, 1:18));
            end
            
            % Check which window we are using...
            curWindow = longWindow;
            
            % Do the DCT
            X = zeros(1, 18);
            for k = 0:17
                X(k+1) = sqrt(2/32) * mdctInput .* curWindow .* cos((n + (32 + 1)/2)*(k + 0.5)*pi/32);
            end
            
            mdctOutput(ch, gr, band, :) = X;
                    
        end
    end
end

% Save the S for the next MDCT
S_prev = S;

% Write the output
F = mdctOutput;

end

