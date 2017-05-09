function frames = getFrames(inputAudio)
%GETFRAMES - Convert a continous audio signal into overlapped frames
%
%   Detailed explanation goes here

% Number of Channels
nChannels = size(inputAudio, 1);

% Buffer each Channels
for ch = 1:nChannels
    chFrames = buffer(inputAudio(ch, :), MP3config.frameSize, MP3config.hopSize);
    frames(ch, :, :) = chFrames'; %#ok<AGROW>
end

end

