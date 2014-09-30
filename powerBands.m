function [ amp_banded, freq_banded ] = powerBands( snippet, Fs )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

[amp, f] = fftGivenFreq( snippet, Fs);
% goal: 1-5hz, 5-10hz, 10-15hz, 15-20hz, 20-40hz,40-80hz
% actual: 0.7805    4.6829    9.3659   14.0488   18.7317   35.1220
bands = {[2:6], [7:12], [13:18], [19:24], [25:45], [46:90]};
amp_banded = zeros(size(bands));
freq_banded = zeros(size(bands));
for i = 1:size(bands,2)
  amp_banded(i) = sum(amp(bands{i}));
  freq_banded(i) = f(bands{i}(1));

end

end

