function [ features ] = extractFeaturesFromFiles( fname_list, dir_name )
    % fname_list = 1xMANY cell array of filenames
    %   Detailed explanation goes here
    features = [];
    

    for fname = fname_list
        disp(['Loading ' fname{1} '(' num2str(size(features,2)) ')']);
        file_top_struct = load( [dir_name fname{1}] ); % contains a struct with one field
        fn=fieldnames( file_top_struct );
        data_file = getfield(file_top_struct,fn{1});
    %                   data: [16x239766 double]
    %        data_length_sec: 600
    %     sampling_frequency: 399.6098
    %               channels: {1x16 cell}
    %               sequence: 1
        new_features = mean(extractFeaturesFromFile(data_file),2);

        features = [features new_features];
    end
end

