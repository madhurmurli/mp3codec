function S = QMF_FilterBank(inputAudio)
%QMF_FilterBank - Time Analysis Block of MP3 Encoder
%
%   32-band, critically sampled analysis-synthesis filter bank.
%   Used to break up input signal into seperate frequency channels.
%
%   
%   See... Pg 15, Eq 2.1
%


% Input Arg Checkings
if size(inputAudio,2) ~= MP3config.frameSize
    error('The QMF Filter Bank Algorithm requires an input frame of size %d samples.', MP3config.frameSize);
elseif size(inputAudio,1) > MP3config.maxChannels
    error('The QMF Filter Bank Algorithm has a maximum of %d input audio channels.', MP3config.maxChannels);
end


% Algorithm Params
nChannels = size(inputAudio,1);                 % 1 = mono, 2 = stereo
kSomething = 64;                                % Still don't know... It's han_size / 8


% Allocate space for the output
S = zeros(MP3config.maxChannels, ...
          MP3config.nGranualsPerFrame, ...
          MP3config.nSubbands, ...
          MP3config.nFilterOperations);


% Initialize Filter State (must be persistent)
persistent x;
if isempty(x)
    % Initialize the Filter State
    x = zeros(MP3config.maxChannels, MP3config.QMFsize);
end


% The Prototype LPF
% Designed using "designfilt"
persistent h;
if isempty(h)
    % Load the Prototype Filter
    h = load('prototypeFilter', 'filter');
    h = h.filter;
end


% Calculate the Window vector
persistent c;
if isempty(c)
    c = zeros(1, length(h.Coefficients));
    for i = 1:length(c)
        if mod(floor(i/kSomething),2) == 1
            c(i) = -1 * h.Coefficients(i);
        else
            c(i) = h.Coefficients(i);
        end
    end
end


% Calculate the Cosine Modulation Matrix
persistent M;
if isempty(M)
    M = zeros(MP3config.nSubbands, kSomething);
    for i = 1:MP3config.nSubbands
        for k = 1:kSomething
            M(i,k) = cos((2*i + 1)*(k-16)*pi/64);
        end
    end
end

% -------------------------------
% Do the Filtering             %%

% For each Granual...
for gr = 1:MP3config.nGranuals
    if gr == 1
        gr_offset = 0;
    else
        gr_offset = MP3config.granualSize;
    end
        
    % For each Channel...
    for ch = 1:nChannels
        
        % Complete one filtering operation
        for it = 0:MP3config.nFilterOperations-1
            % Slide the QMF Window over the Granual, shifting out old data with new data
            % Remove old data
            x(ch, MP3config.QMFsize:-1:MP3config.QMFhop+1) = x(ch, MP3config.QMFsize-MP3config.QMFhop:-1:1);
            % Add new data
            x(ch, MP3config.QMFhop:-1:1) = inputAudio(ch, gr_offset+it*QMFhop+1:gr_offset+(it+1)*QMFhop);
            
            % Apply the Window C to Data Vector X
            z = x(ch, :).*c;
            
            % Calculate y
            y = zeros(1, kSomething);
            for i = 1:kSomething
                y(i) = sum(z(i:kSomething:MP3config.QMFsize));
            end
            
            % Calculate the 32 subband samples
            for i = 1:MP3config.nSubbands
                S(ch, gr, i, it+1) = sum(y.*M(i,:));
            end
        end
    end
end

end

