function [ features ] = extractFeaturesFromFiles( fname_list )
    % fname_list = 2xMANY cell array of filenames where first row is names
    % and second row is directory
    %   Detailed explanation goes here
    features = [];
    
    disp(['Loading ' num2str(length(fname_list)) ' files']);
    i = 0;
    for fname = fname_list
        i = i + 1;
        if mod(i,20)==0; disp([num2str(floor(100.0 * i / length(fname_list))) '%']); end
%         disp(['Loading ' fname{1} '(' num2str(size(features,2)) ')']);
        file_top_struct = load( [fname{2} '/' fname{1}] ); % contains a struct with one field
        fn=fieldnames( file_top_struct );
        data_file = getfield(file_top_struct,fn{1});
    %                   data: [16x239766 double]
    %        data_length_sec: 600
    %     sampling_frequency: 399.6098
    %               channels: {1x16 cell}
    %               sequence: 1
        new_features = [
            extractGlobalFeaturesFromFile(data_file);
        ];
        features = [features new_features];
    end
end

