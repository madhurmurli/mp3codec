function frames = getFrames(inputAudio)
%GETFRAMES - Convert a continous audio signal into overlapped frames
%
%   Detailed explanation goes here

% Number of Channels
nChannels = size(inputAudio, 1);

% Zero Pad the Audio Signal
zeroPad = zeros(nChannels, MP3config.hopSize);
inputAudio = [zeroPad inputAudio zeroPad];

% Determine the number of frames
nFrames = floor(size(inputAudio, 2) / MP3config.hopSize) - 1;

% Allocate space for the output frames
frames = zeros(nChannels, nFrames, MP3config.frameSize);

% Break up the Audio into frames
for ch = 1:nChannels
    for nf = 1:nFrames
        a = inputAudio(ch, (nf-1)*MP3config.hopSize+1:(nf-1)*MP3config.hopSize+MP3config.frameSize);
        frames(ch, nf, :) = a;
    end
end

end

