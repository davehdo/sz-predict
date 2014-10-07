function [ output_args ] = inspectTimeSeries( signal, Fs, each_row_shows)
    %UNTITLED13 Summary of this function goes here
    %   Detailed explanation goes here

    points_per_row = floor(Fs*each_row_shows);

    figure
    for row = 1:6
        dat = signal([1:points_per_row] + points_per_row*row);

%         reshaped = segmentSignal(dat, Fs, 5); %seconds

%         feature = extractPowerBands(reshaped, Fs);

        subplot(6,1,row);
    %     plot(linspace(0,each_row_shows, length(feature)), feature, 'r');
    %     subplot(6,1,2*row);
    %     hold on
         plot(linspace(0,each_row_shows, length(dat)), dat);
    %     hold off
        if row == 6; xlabel('Time (sec)'); end
    end
end

