function [ all_files ] = filesInDirectories( directory_array )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    all_files = {}
    for j = 1:size(directory_array,1)
        directory = directory_array{j};
        files = filesInDir( directory );
        all_files = horzcat( all_files, files )
    end
end

