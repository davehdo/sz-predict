% 

% file_top_struct = load( 'data/Dog_1/training_0/Dog_1_interictal_segment_0001.mat' ); % contains a struct with one field

file_top_struct = load( 'data/Dog_1/training_1/Dog_1_preictal_segment_0001.mat' ); % contains a struct with one field

fn=fieldnames( file_top_struct );
data_file = getfield(file_top_struct,fn{1});

    %                   data: [16x239766 double]
    %        data_length_sec: 600
    %     sampling_frequency: 399.6098
    %               channels: {1x16 cell}
    %               sequence: 1
    
figure(1);

each_row_shows = 20; % sec
Fs = getfield(data_file, 'sampling_frequency');
all_dat = (getfield(data_file, 'data'));
points_per_row = floor(Fs*each_row_shows);
n_channels = size(all_dat,1);

stdev = std(all_dat(:));

for row = 1
    dat = all_dat(:,[1:points_per_row] + points_per_row*row);
    
%     window_size_seconds = 0.01; %seconds
%     n_points_per_window = ceil(Fs * window_size_seconds);
%     n_windows = floor(length(dat) / n_points_per_window);

%     trimmed = dat(1:(n_windows*n_points_per_window));

%     reshaped = reshape(trimmed, n_points_per_window, n_windows);

%     feature = abs(dat) > 3*stdev;
    offset = [[2:n_channels+1] * 10 * stdev]' * ones(1, size(dat,2) );
    
    plot(linspace(0,each_row_shows, size(dat,2)), dat + offset, 'b');

    rms =  mean(dat(:,:).^2,1) .^ 0.5;
    rms =  mean(dat(:,:).^2,1) .^ 0.5;
    stdev_rms = std(rms);
    
    hold on

    plot(linspace(0,each_row_shows, size(dat,2)), rms + 10 * stdev, 'r');
    
    stem(linspace(0,each_row_shows, size(dat,2)), (rms > stdev_rms * 5) * 50.0 , 'g');
    hold off

    
end