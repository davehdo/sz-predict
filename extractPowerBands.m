function [ bands ] = extractPowerBands( signal, Fs )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

bands = zeros( 6, size(signal, 2) );

for i = 1:size(signal, 2)
    
    snippet = signal(:,i)';
    
    bands(:,i) = powerBands( snippet, Fs );
    
    
end


end

