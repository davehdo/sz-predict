function [ amp, f ] = fftGivenFreq( signal, sampleFreq )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

L = size(signal,2);
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(signal,NFFT)/L;
f = sampleFreq/2*linspace(0,1,NFFT/2+1);
amp = 2*abs(Y(1:NFFT/2+1));

end

