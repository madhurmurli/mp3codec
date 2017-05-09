function F = MDCT(S)
%MDCT -- Modified Discrete Cosine Transform
%
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
for gr = 1:MP3config.nGranualsPerFrame
    for ch = 1:size(S,1)
        % Compensate for inversion in the analysis filter bank
        % Inversion is applied only to the odd time samples of the odd subbands
        band = 2:2:32;
        time_index = 2:2:18;
        S(ch, gr, band, time_index) = -S(ch, gr, band, time_index);
    end
end


% -------------------------------
% Do the MDCT

% Keep the previous S struct
persistent S_prev;

% Inputs and Outputs
mdctInput = zeros(1, MP3config.mdctSize);
mdctOutput = zeros(size(S,1), size(S,2), size(S,3), 3, size(S,4));
X = zeros(1, MP3config.mdctSize/2);
n = 0:35;

% For each granual...
for gr = 1:MP3config.nGranualsPerFrame
    
    % For each channel...
    for ch = 1:size(S,1)
        
        % For each band...
        for band = 1:MP3config.nSubbands
        
            % Build the input to the DCT
            if gr == 1
                if isempty(S_prev)
                    % If this is the first frame, the previous granual is all zeros.
                    mdctInput(1:18) = zeros(1,MP3config.mdctSize/2);
                else
                    mdctInput(1:18) = squeeze(S_prev(ch, 2, band, 1:18));
                end
                mdctInput(19:36) = squeeze(S(ch, gr, band, 1:18));
            else
                mdctInput(1:18) = squeeze(S(ch, gr-1, band, 1:18));
                mdctInput(19:36) = squeeze(S(ch, gr, band, 1:18));
            end
            
            % Check which window we are using...
            if MP3config.doWindowSwitching
                % Pick the window based on Psycho Model
            else
                curWindow = longWindow;
            end
            
            % If we have a shortWindow... we need to do three DCTs
            if size(curWindow,1) == size(shortWindows,1)
                % Do the DCT for each short window
                for w = 1:3
                    for k = 0:17
%                         for n = 0:35
                            X(k+1) = sqrt(2/32) * sum(mdctInput .* curWindow(w,:) .* cos((n + (32 + 1)/2)*(k + 0.5)*pi/32));
%                         end
                    end
                    mdctOutput(ch, gr, band, w, :) = X;
                end
            else
                % Do the DCT
                X = zeros(1, 18);
                for k = 0:17
                    X(k+1) = sqrt(2/32) * sum(mdctInput .* curWindow .* cos((n + (32 + 1)/2)*(k + 0.5)*pi/32));
                end
                mdctOutput(ch, gr, band, 1, :) = X;
            end
        end
    end
end

% Save the S for the next MDCT
S_prev = S;

% Write the output
F = mdctOutput;

end

