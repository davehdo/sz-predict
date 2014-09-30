function [ envelope ] = extractEnvelope( signal )
% columns each represent one timepoint 

envelope = sum(signal .^ 2,1);

end

