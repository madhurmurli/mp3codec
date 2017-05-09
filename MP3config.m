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
    end
    
    methods
    end
    
end

