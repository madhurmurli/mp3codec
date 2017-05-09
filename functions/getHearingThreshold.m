function hearingThreshold = getHearingThreshold(N, fs)
%GETHEARINGTHRESHOLD - Gets the Threshold of Hearing

% Hearing Threshold level per FFT Bin
hearingThreshold = zeros(1, N);

% Calculate the Threshold for each bin freq
for i = 1:N
    freq = (i-1) * 0.5 * fs / N;
    hearingThreshold(i) = 3.64*(freq^-0.8) - 6.5*exp(-0.6*((f-3.33)^2)) + 1e-3*(freq^4);
end

end

