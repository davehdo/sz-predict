function [ output_args ] = extractMedianFrequency( signal, Fs )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

output_args = zeros(1, size(signal,2));
for i = 1:size(signal, 2)
    
    snippet = signal(:,i)';
    
    [amp, f] = fftGivenFreq( snippet, Fs );
    output_args(i) = sum(amp .* f) / sum(amp);
    
end

end

