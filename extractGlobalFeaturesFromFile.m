function [ features ] = extractGlobalFeaturesFromFile( data_file )
    % slope of spike count
    % spike density
    % variability in spike count over time
    %
    % params:
    %   data_file is a 1x1 struct that looks like this:
    %                   data: [16x239766 double]
    %        data_length_sec: 600
    %     sampling_frequency: 399.6098
    %               channels: {1x16 cell}
    %               sequence: 1
    
    tail = 60; % sec
    head = 60; % sec (length at which to crop the data file)

    Fs = getfield(data_file, 'sampling_frequency');
    raw_data = getfield(data_file, 'data');
    raw_data_length = size(raw_data,2);

    nChannels = size(raw_data,1);
    
    % the head can serve as a baseline for each clip
    nPoints_head = min( ceil( head * Fs ), raw_data_length);
    cropped_head = raw_data(:,1:nPoints_head);

    % the tail probably has the most predictive features
    nPoints_tail = min( ceil( tail * Fs ), raw_data_length);
    cropped_tail = raw_data(:,(raw_data_length - nPoints_tail + 1):raw_data_length);

    %% combine all channels into one
    combined_head = sum(cropped_head,1);
    combined_tail = sum(cropped_tail,1);

    %% add a sine wave to the signal to demonstrate the FFT works
    %timescale = linspace(0,T, size(cropped,2));
    %sine = 20 * sin(2*pi*50*timescale) + 10 * sin(2*pi*120*timescale);
    %cropped = cropped + [sine;sine]

    
    stdev = std(sum(raw_data,1));
    spikes_in_head = abs(combined_head) > (3*stdev);
    spikes_in_tail = abs(combined_tail) > (3*stdev);
 
    slope_spike_count = sum(spikes_in_tail) - sum(spikes_in_head);
    spike_density = 1.0 * sum(spikes_in_tail) / tail;

    % variability
    window_size_seconds = 10; %seconds
    n_points_per_window = ceil(Fs * window_size_seconds);
    n_windows = floor(raw_data_length / n_points_per_window);
    trimmed = raw_data(1:(n_windows*n_points_per_window));
    reshaped = reshape(trimmed, n_points_per_window, n_windows);
    
    variability_in_spike_count = std(sum(abs(reshaped) > (3*stdev),1));
    
    features = [
        slope_spike_count;
        spike_density;
        variability_in_spike_count;
    ];
end

