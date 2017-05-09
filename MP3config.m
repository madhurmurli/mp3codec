classdef MP3config
    %MP3CONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        % GLOBAL PARAMETERS
        
        % The maximum number of audio channels
        maxChannels = 2;
        
        % Frame Size (in samples)
        frameSize = 1152;
        
        % Hop Size (in samples)
        hopSize = 576;
        
        % Granual Size (in samples)
        % 1/2 the Frame Size
        granualSize = 576;
        
        % Number of Granuals per Frame
        nGranualsPerFrame = 2;
        
        % ------------------------------------------------------
        
        % PSYCHO ACOUSTIC MODEL PARAMETERS
        
        % FFT Size
        fftSize = 1024;
        
        % dBSPL Bias
        splBias = 90.3;
        
        % Bark Band Limits
        barkBandLimits = [100,200,300,400,510,630,770,920,1080,1270,1480,1720,2000,2320,2700,3150,3700,4400,5300,6400,7700,9500,12000,15500,25000];
        
        % ------------------------------------------------------
        
        % QMF_FILTERBANK PARAMETERS
        
        % Number of Filters in Filter Bank
        nFilters = 32;
        
        % Number of Subbands
        nSubbands = 32;
        
        % QMF Filter Size
        QMFsize = 512;
        
        % QMF Hop Size
        QMFhop = 32;
        
        % Number of Filter Operations per Granual
        % GranualSize / QMFhop
        nFilterOperations = 18;
        
        % ------------------------------------------------------
        
        % MDCT PARAMETERS
        
        % MDCT Size
        mdctSize = 36;
        
        % Do Window Switching?
        doWindowSwitching = false;
        
        % ------------------------------------------------------
        
        % PLOTTING FLAGS
        
        % Plot a
    end
    
    methods
    end
    
end

