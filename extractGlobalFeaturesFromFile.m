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
    
    tail_duration = 120; % sec

    Fs = getfield(data_file, 'sampling_frequency');
    raw_data = getfield(data_file, 'data');
    raw_data_length = size(raw_data,2);

    %% trim the data to keep the last minute only
    points_to_keep = min( floor(tail_duration * Fs), raw_data_length );
    
    raw_data = raw_data(:, (end-points_to_keep):end);
    
    %% Extract features
    % combine all leads into one signal using RMS
    rms_signal = mean(raw_data .^ 2,1) .^ 0.5;
    
    % get a measure of the baseline variability of the signal
    stdev = std(rms_signal);

    % a series of ones and zeros
    spikes = (rms_signal) > (4*stdev);

    %% add a sine wave to the signal to demonstrate the FFT works
    %timescale = linspace(0,T, size(cropped,2));
    %sine = 20 * sin(2*pi*50*timescale) + 10 * sin(2*pi*120*timescale);
    %cropped = cropped + [sine;sine]

    %%

    power_bands = extractPowerBands( raw_data', Fs); % 8 features x 16 channels
   
       
% use specExtractFeaturesFromFiles to inspect the power of features to
% differentiate
    features = [
        sum( spikes ); % useful, predicts interictal
        power_bands(:);
%         10 + rand;
%         rand;
    ];

end

