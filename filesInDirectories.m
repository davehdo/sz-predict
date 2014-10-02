function [ all_files ] = filesInDirectories( directories )
% returns a 2xMANY cell array where the top row is filenames and bottom row
% is directory names
%         'Dog_5_preictal_segment_0021.mat'
%         'data/Dog_5/training_1'
    all_files = {};
    for directory = directories'
        
        dir_list = dir(directory{1});
    % 482x1 struct array with fields:
    %     name
    %     date
    %     bytes
    %     isdir
    %     datenum
        for i = 1:size(dir_list,1);
            dir_item = dir_list(i);
            if getfield(dir_item, 'isdir')  == 0
               all_files = horzcat( all_files, {getfield(dir_item, 'name'); directory{1}});
            end
        end
    
    end

end

