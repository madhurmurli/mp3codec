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
frameSize = 1152;
if size(inputAudio,2) ~= frameSize
    error('The QMF Filter Bank Algorithm requires an input frame of size %d samples.', frameSize);
end


% Algorithm Params
nChannels = size(inputAudio,1);
nGranuals = 2;
nSubbands = 32;
nIterations = 18;
kSomething = 64;

han_size = 512;
gr_offset = 0;
scale = 1;


% Allocate space for the output
S = zeros(nChannels, nGranuals, nSubbands, nIterations);


% Load the Prototype Filter
h = load('prototypeFilter', 'filter');
h = h.filter;


% Get the first frame
x = inputAudio(:, 1:han_size);


% Calculate the Window
c = zeros(1, length(h.Coefficients));
for i = 1:length(c)
    if mod(floor(i/kSomething),2)
        c(i) = -1 * h.Coefficients(i);
    else
        c(i) = h.Coefficients(i);
    end
end


% Calculate the Cosine Modulation Matrix
M = zeros(nSubbands, kSomething);
for i = 1:nSubbands
    for k = 1:kSomething
        M(i,k) = cos((2*i + 1)*(k-16)*pi/64);
    end
end


% 
for gr = 1:nGranuals
    for ch = 1:nChannels
        for it = 0:nIterations-1
            x(ch, han_size:-1:nSubbands+1) = x(ch, han_size-nSubbands:-1:1);
            x(ch, nSubbands:-1:1) = inputAudio(ch, gr_offset+it*nSubbands+1:gr_offset+(it+1)*nSubbands)/scale;
            
            % Apply the Window C to vector X
            z = x(ch, :).*c;
            
            % Calculate y
            y = zeros(1, kSomething);
            for i = 1:kSomething
                y(i) = sum(z(i:kSomething:han_size));
            end
            
            % Calculate the 32 subband samples
            for i = 1:nSubbands
                S(ch, gr, i, it+1) = sum(y.*M(i,:));
            end
            
            a = 6;
            
            
        end
    end
end
            
        


end

