file_top_struct = load( 'data/Dog_1/training_0/Dog_1_interictal_segment_0001.mat' ); % contains a struct with one field

%file_top_struct = load( 'data/Dog_1/training_1/Dog_1_preictal_segment_0001.mat' ); % contains a struct with one field

fn=fieldnames( file_top_struct );
data_file = getfield(file_top_struct,fn{1});

    %                   data: [16x239766 double]
    %        data_length_sec: 600
    %     sampling_frequency: 399.6098
    %               channels: {1x16 cell}
    %               sequence: 1
    
figure(1);

each_row_shows = 30; % sec
Fs = getfield(data_file, 'sampling_frequency');
all_dat = mean(getfield(data_file, 'data'),1);
points_per_row = floor(Fs*each_row_shows);

stdev = std(all_dat);

for row = 1:6
    dat = all_dat([1:points_per_row] + points_per_row*row);
    
    window_size_seconds = 1; %seconds
    n_points_per_window = ceil(Fs * window_size_seconds);
    n_windows = floor(length(dat) / n_points_per_window);

    trimmed = dat(1:(n_windows*n_points_per_window));

    reshaped = reshape(trimmed, n_points_per_window, n_windows);

      
    
   feature = extractPowerBands(reshaped, Fs);
    
    
    subplot(6,1,2*row-1);
    plot(linspace(0,each_row_shows, length(feature)), feature, 'r');
    subplot(6,1,2*row);
    hold on
    plot(linspace(0,each_row_shows, length(dat)), dat);
    hold off
    if row == 6
        xlabel('Time (sec)')
    end
    

end