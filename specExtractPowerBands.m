% file_top_struct = load( 'data/Dog_1/training_0/Dog_1_interictal_segment_0001.mat' ); % contains a struct with one field

file_top_struct = load( 'data/Dog_1/training_1/Dog_1_preictal_segment_0001.mat' ); % contains a struct with one field

fn=fieldnames( file_top_struct );
data_file = getfield(file_top_struct,fn{1});

    %                   data: [16x239766 double]
    %        data_length_sec: 600
    %     sampling_frequency: 399.6098
    %               channels: {1x16 cell}
    %               sequence: 1
    
Fs = getfield(data_file, 'sampling_frequency');

rms = mean(getfield(data_file, 'data') .^ 2 ,1) .^ 0.5;
inspectTimeSeries( rms, Fs, 20 );
title('RMS')

figure
a = extractPowerBands( segmentSignal(rms, Fs, 10), Fs );
bar(a);
title('Frequency bands for RMS signal');

all_dat = mean(getfield(data_file, 'data'),1);
inspectTimeSeries( all_dat, Fs, 20 );
title('mean');

figure
b = extractPowerBands( segmentSignal(all_dat, Fs, 10), Fs );
bar(b);
title('Frequency bands for mean signal');
