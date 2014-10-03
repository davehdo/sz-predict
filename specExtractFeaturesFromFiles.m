% this script loads data from preictal and postictal
% then extracts features and averages them across each set
% this allos the user to see how each feature performs in separating the 
%   populations

clear

%% Load and clip the files
preictal_directories = {
     'data/Dog_1/training_1';
     'data/Dog_2/training_1';
     'data/Dog_5/training_1';
};

interictal_directories = {
    'data/Dog_1/training_0';
     'data/Dog_2/training_0';
     'data/Dog_5/training_0';
};

preictal_features = extractFeaturesFromFiles( filesInDirectories(preictal_directories) );

interictal_features = extractFeaturesFromFiles( filesInDirectories(interictal_directories) );

%%
preictal_mean = mean( preictal_features, 2 )
preictal_stderr = std( preictal_features' )' ./ sqrt( size(preictal_features,2) );
interictal_mean = mean( interictal_features, 2 );
interictal_stderr = std( interictal_features' )' ./ sqrt( size(interictal_features,2) );

combined_stderr = preictal_mean ./ interictal_mean .* sqrt( (preictal_stderr ./ preictal_mean) .^ 2 + (interictal_stderr ./ interictal_mean) .^ 2 ) 
%%
figure
title('Likelihood ratio of preictal based on features');
errorbar( mean( preictal_features, 2 ) ./ mean( interictal_features, 2 ), combined_stderr )
hold on
plot([1, size(preictal_features, 1)], [1, 1], 'r');
hold off


