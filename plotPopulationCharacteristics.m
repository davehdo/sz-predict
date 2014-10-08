function [ null ] = plotPopulationCharacteristics( preictal_features, interictal_features )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

    preictal_mean = mean( preictal_features, 2 )
    preictal_stderr = std( preictal_features' )' ./ sqrt( size(preictal_features,2) );
    interictal_mean = mean( interictal_features, 2 );
    interictal_stderr = std( interictal_features' )' ./ sqrt( size(interictal_features,2) );

    combined_stderr = preictal_mean ./ interictal_mean .* sqrt( (preictal_stderr ./ preictal_mean) .^ 2 + (interictal_stderr ./ interictal_mean) .^ 2 ) 
    %%
    
    title('Likelihood ratio of preictal based on features');
    errorbar( mean( preictal_features, 2 ) ./ mean( interictal_features, 2 ), combined_stderr )
    hold on
    plot([1, size(preictal_features, 1)], [1, 1], 'r');
    hold off
end

