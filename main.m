clear

%% Load and clip the files
preictal_directories = {
     'data/Dog_1/training_1';
     'data/Dog_2/training_1';
     'data/Dog_3/training_1';
     'data/Dog_5/training_1';
};

interictal_directories = {
     'data/Dog_1/training_0';
     'data/Dog_2/training_0';
     'data/Dog_3/training_0';
     'data/Dog_5/training_0';
};

test_directories = {
    'data/Dog_1/testing';
    'data/Dog_2/testing';
    'data/Dog_3/testing';
    'data/Dog_5/testing';
};

preictal_features = extractFeaturesFromFiles( filesInDirectories(preictal_directories) );
preictal_learning_signal = ones(1, size(preictal_features, 2));

interictal_features = extractFeaturesFromFiles( filesInDirectories(interictal_directories) );
interictal_learning_signal = zeros(1, size(interictal_features, 2));

%%
plotPopulationCharacteristics( preictal_features, interictal_features );

%% concatenate all the data
concat_features = [preictal_features interictal_features];
concat_learning_signal = [preictal_learning_signal interictal_learning_signal];

percent_used_for_training = 80;

indexes_for_training = rand(1, size(concat_features,2) ) < percent_used_for_training / 100.0;

disp(['Using ' num2str(percent_used_for_training) ' for training (' num2str(sum(indexes_for_training)) ' of ' num2str(length(indexes_for_training)) ')']);


training_features = concat_features(:, indexes_for_training);
training_learning_signal = concat_learning_signal(:, indexes_for_training);

testing_features = concat_features(:, indexes_for_training == 0);
testing_learning_signal = concat_learning_signal(:, indexes_for_training == 0);

%% train the random forest model and test on known test set
% classification: 
X_trn = training_features';
Y_trn = training_learning_signal';
disp('Training');
model_class = classRF_train(X_trn,Y_trn,500,3);
disp('Training complete');

X_tst = testing_features';
Y_tst = testing_learning_signal';
Y_hat = classRF_predict(X_tst,model_class);

err_rate = length(find(Y_hat~=Y_tst)) / length(Y_hat); %number of misclassification

disp(['Error rate ' num2str(err_rate)]);

%% Save the model 
% creates the directory
if exist('models', 'file') == 0
   mkdir('models'); 
end

if isfield(model_class, 'serial')
    disp('this model appears to have been saved already');
else
    % look for next available serial number
    i = 1;
    while exist(['models/model_' num2str(i) '.mat'], 'file') ~= 0
        i = i + 1;
    end
    model_class.serial = ['model_' num2str(i)];
    save(['models/model_' num2str(i) '.mat'], 'model_class');
    disp(['Saved as models/model_' num2str(i) '.mat']);
end


%% Load and test the test set
result=input('Use cached test set features? (Do this if feature extraction algorithm has not changed) y/n ','s');

if result == 'n'
    disp('re-extracting features from the test data set');
    test_features = extractFeaturesFromFiles( filesInDirectories(test_directories) );
    X_tst = test_features';

    save(['features_from_test_set.mat'], 'X_tst');
else
    disp('loaded cached features from last time');
    load('features_from_test_set.mat');
end

disp('Done. Test data are loaded and ready to run predictions');

% Run the predictions on test data and plot them

Y_hat = classRF_predict(X_tst,model_class);
disp([ num2str(100.0 * mean(Y_hat)) '% of test data predicted to be seizure']);
figure;
stem(Y_hat)
title('predictions on test data');
% err_rate = length(find(Y_hat~=Y_tst)) %number of misclassification

%% Save the predictions to a CSV
all_files = filesInDirectories(test_directories);

model_class.serial; % this should exist. this line will trigger exception if not

i = 1;
while exist(['submissions/partial_' num2str(i) '.csv'], 'file') ~= 0
    i = i + 1;
end

fid = fopen(['submissions/partial_' num2str(i) '.csv'],'w');
j = 0;
fprintf( fid, ['Model: ' model_class.serial '\n']);
for fname = all_files
    j = j + 1;
   fprintf( fid, [ fname{1} ',' num2str(Y_hat(j)) '\n' ] ); 
end
fclose(fid);
disp(['Saved as ' 'submissions/partial_' num2str(i) '.csv']);

