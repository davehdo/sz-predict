file_top_struct = load( 'data/Dog_1/training_0/Dog_1_interictal_segment_0001.mat' ); % contains a struct with one field
% file_top_struct = load( 'data/Dog_1/training_1/Dog_1_preictal_segment_0001.mat' ); % contains a struct with one field

fn=fieldnames( file_top_struct );
data_file = getfield(file_top_struct,fn{1});

    %                   data: [16x239766 double]
    %        data_length_sec: 600
    %     sampling_frequency: 399.6098
    %               channels: {1x16 cell}
    %               sequence: 1

a = extractGlobalFeaturesFromFile( data_file )
    
