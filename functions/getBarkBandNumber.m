function bark = getBarkBandNumber(f)
    bark = find(f < MP3config.barkBandLimits, 1);
end