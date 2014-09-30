function [ files ] = filesInDir( dir_name )
    %   returns a cell-array of filenames
    dir_to_load = dir_name

    files = {};
    dir_list = dir(dir_to_load);
    % 482x1 struct array with fields:
    %     name
    %     date
    %     bytes
    %     isdir
    %     datenum
    for i = 1:size(dir_list,1);
        dir_item = dir_list(i);
        if getfield(dir_item, 'isdir')  == 0
            files{ length(files(:))+1 } = [getfield(dir_item, 'name')];
        end
    end
end