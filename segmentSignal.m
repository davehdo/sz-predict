function [ reshaped ] = segmentSignal( signal, Fs, window_size_seconds )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here


    n_points_per_window = ceil(Fs * window_size_seconds);
    n_windows = floor(length(signal) / n_points_per_window);
    trimmed = signal(1:(n_windows*n_points_per_window));
    reshaped = reshape(trimmed, n_points_per_window, n_windows);
    
end

