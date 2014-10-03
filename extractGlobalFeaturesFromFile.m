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
    
    tail = 120; % sec
    head = 60; % sec (length at which to crop the data file)

    Fs = getfield(data_file, 'sampling_frequency');
    raw_data = getfield(data_file, 'data');
    raw_data_length = size(raw_data,2);

    % combine all leads into one signal
    combined = sum(raw_data,1);
    
    % get a measure of the baseline variability of the signal
    stdev = std(combined);

    % a series of ones and zeros
    spikes = abs(combined) > (3*stdev);

    % the head can serve as a baseline for each clip
    nPoints_head = min( ceil( head * Fs ), raw_data_length);
    spikes_in_head = spikes(:,1:nPoints_head);

    % the tail probably has the most predictive features
    nPoints_tail = min( ceil( tail * Fs ), raw_data_length);
    spikes_in_tail = spikes(:,(raw_data_length - nPoints_tail + 1):raw_data_length);

    raw_tail = combined(:,(raw_data_length - nPoints_tail + 1):raw_data_length);
    
    %% add a sine wave to the signal to demonstrate the FFT works
    %timescale = linspace(0,T, size(cropped,2));
    %sine = 20 * sin(2*pi*50*timescale) + 10 * sin(2*pi*120*timescale);
    %cropped = cropped + [sine;sine]

    slope_spike_count = sum(spikes_in_tail) - sum(spikes_in_head);
%     spike_density = 1.0 * sum(spikes) / raw_data_length;
    spike_density_tail = 1.0 * sum(spikes_in_tail) / tail;

    % variability in spike count for 10-sec windows
    reshaped_10 = segmentSignal( spikes, Fs, 10 );
    
    variability_in_spike_count = std(mean(reshaped_10,1));
    
    % because very frequent 'spiking' can lead to extreme values
    % we create another indicator of spiking that only counts once per
    % 0.05-sec windows
%     reshaped_05 = segmentSignal(abs(raw_tail) > (4*stdev), Fs, 0.05);
    
%     spikes_per_05 = any(reshaped_05,1); 
%     spike_density_05 = 1.0 * sum(spikes_per_05) / tail;
    
    % frequency power bands
    reshaped_10b = segmentSignal(raw_tail, Fs, 5); % 5 sec is determined to separate better than 10 or 20 second windows

    power_bands = extractPowerBands(reshaped_10b, Fs);
   
    power_bands_mean = mean( power_bands,2 );
    
    
% use specExtractFeaturesFromFiles to inspect the power of features to
% differentiate
    features = [
        sum(abs(combined) > (4*stdev)); % useful, predicts interictal
        sum(abs(raw_tail) > (4*stdev)); % very useful, predicts interictal
        slope_spike_count; % useful
        spike_density_tail; % useful
%         spike_density; % not useful
        variability_in_spike_count; % useful
%         spike_density_05; % not useful
        power_bands_mean; % 6 bands, some are useful
%         10 + rand;
%         rand;
        sum(raw_tail); %useful
%         mean(abs(raw_tail)); % not useful?
        mean(raw_tail .^ 2); % useful
        sum(raw_tail(2:end) - raw_tail(1:end-1)); % variable usefulness
%         stdev; % not useful
%         std(raw_tail); % not useful
    ];
end

