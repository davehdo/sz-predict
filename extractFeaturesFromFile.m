function [ features ] = extractFeaturesFromFile( data_file )
    % data_file is a 1x1 struct that looks like this:
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
    nPoints_head = min( ceil( head * Fs ), raw_data_length);
    cropped_head = raw_data(:,1:nPoints_head);

    nPoints_tail = min( ceil( tail * Fs ), raw_data_length);
    cropped_tail = raw_data(:,(raw_data_length - nPoints_tail + 1):raw_data_length);

    %% combine all channels into one
    combined_head = sum(cropped_head,1);
    combined_tail = sum(cropped_tail,1);

    %% add a sine wave to the signal to demonstrate the FFT works
    %timescale = linspace(0,T, size(cropped,2));
    %sine = 20 * sin(2*pi*50*timescale) + 10 * sin(2*pi*120*timescale);
    %cropped = cropped + [sine;sine]

    %% Go through windows
    window_size_seconds = 0.8; %seconds
    n_points_per_window = ceil(Fs * window_size_seconds);
    n_windows_head = floor(nPoints_head / n_points_per_window);
    n_windows_tail = floor(nPoints_tail / n_points_per_window);

    trimmed_head = combined_head(1:(n_windows_head*n_points_per_window));
    trimmed_tail = combined_tail(1:(n_windows_tail*n_points_per_window));

    reshaped_head = reshape(trimmed_head, n_points_per_window, n_windows_head);
    reshaped_tail = reshape(trimmed_tail, n_points_per_window, n_windows_tail);

        a = extractEnvelope(reshaped_head);
        b = extractMedianFrequency( reshaped_head, Fs);
        c = extractPowerBands( reshaped_head, Fs );

    features = [
        a;
        b;
        c;
        extractEnvelope(reshaped_tail) ./ a;
        extractMedianFrequency( reshaped_tail, Fs) ./ b;
        extractPowerBands( reshaped_tail, Fs ) ./ c;
    ];
end

