file_top_struct = load( 'data/Dog_1/training_0/Dog_1_interictal_segment_0001.mat' ); % contains a struct with one field
fn=fieldnames( file_top_struct );
interictal_file = getfield(file_top_struct,fn{1});


file_top_struct = load( 'data/Dog_1/training_1/Dog_1_preictal_segment_0001.mat' ); % contains a struct with one field
fn=fieldnames( file_top_struct );
preictal_file = getfield(file_top_struct,fn{1});

    %                   data: [16x239766 double]
    %        data_length_sec: 600
    %     sampling_frequency: 399.6098
    %               channels: {1x16 cell}
    %               sequence: 1

    
inter_features = extractGlobalFeaturesFromFile( interictal_file );
pre_features =  extractGlobalFeaturesFromFile( preictal_file );

figure
title('Likelihood ratio of preictal based on features');
bar(pre_features ./ inter_features)
hold on
plot([1, length(pre_features)], [1, 1], 'r');
hold off