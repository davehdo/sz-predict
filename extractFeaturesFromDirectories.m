function [ features ] = extractFeaturesFromDirectories( directory_array )
%   Detailed explanation goes here
    features = [];
    
    for i = 1:size(directory_array,1)
        directory = directory_array(i);
        files = filesInDir( directory{1} );
        features = [features extractFeaturesFromFiles(files, [directory{1} '/'])];
    end
end

