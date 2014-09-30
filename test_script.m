clear

fname = {'Dog_1/Dog_1_interictal_segment_0051.mat'};
disp(['Loading ' fname{1} ]);
file_top_struct = load( fname{1} ); % contains a struct with one field
fn=fieldnames( file_top_struct );
data_file = getfield(file_top_struct,fn{1});
%                   data: [16x239766 double]
%        data_length_sec: 600
%     sampling_frequency: 399.6098
%               channels: {1x16 cell}
%               sequence: 1
new_features = mean(extractFeaturesFromFile(data_file),2);


size(new_features)

plot(new_features)
