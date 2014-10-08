function [ features ] = extractFeaturesFromFiles( fname_list )
    % fname_list = 2xMANY cell array of filenames where first row is names
    % and second row is directory
    %   Detailed explanation goes here
    features = [];
    
    h = waitbar(0,'Initializing waitbar...');
%     disp(['Loading ' num2str(length(fname_list)) ' files...']);
    i = 0;
    for fname = fname_list
        i = i + 1;
        waitbar(1.0 * i / length(fname_list),h,['Loading ' num2str(i) ' of ' num2str(length(fname_list)) ': ' fname{1}]);

        %         disp(['Loading ' fname{1} '(' num2str(size(features,2)) ')']);
        file_top_struct = load( [fname{2} '/' fname{1}] ); % contains a struct with one field
        fn=fieldnames( file_top_struct );
        data_file = getfield(file_top_struct,fn{1});
        
        n_channels = size(data_file.data,1 );
        if n_channels ~= 16
            disp(['Warning: There are ' num2str(n_channels) ' channels. Will add empty channels to reach 16.']);
            padding = 16 - n_channels;
            
            if padding > 0
                data_length = size(data_file.data, 2);
                data_file.data = [data_file.data; zeros(padding, data_length)];
            end
        end
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
    close(h);
end

