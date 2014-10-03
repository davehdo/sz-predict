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

%% concatenate all the data
concat_features = [preictal_features interictal_features];
concat_learning_signal = [preictal_learning_signal interictal_learning_signal];

use_half_for_offline_testing = true

if use_half_for_offline_testing  % set to true if 
    disp('Using half of training data to allow offline testing');
    training_features = concat_features(:, 1:2:end);
    training_learning_signal = concat_learning_signal(:, 1:2:end);

    testing_features = concat_features(:, 2:2:end);
    testing_learning_signal = concat_learning_signal(:, 2:2:end);
else
    disp('Using all training data');
    training_features = concat_features;
    training_learning_signal = concat_learning_signal;

    testing_features = concat_features;
    testing_learning_signal = concat_learning_signal;
end

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

disp(['error rate ' num2str(err_rate)]);

%% Save the model 
if exist('models', 'file') == 0
   mkdir('models'); 
end

i = 1;
while exist(['models/model_' num2str(i) '.mat'], 'file') ~= 0
    i = i + 1;
end

save(['models/model_' num2str(i) '.mat'], 'model_class');
disp(['Saved as models/model_' num2str(i) '.mat']);

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

%%
%
% model_filenames = {'model_8', 'model_9', 'model_10'};
% Y_hats = cell( size(model_filenames) );
% 
% for i=1:length(model_filenames); 
%     disp(['Loading models/' model_filenames{i}]);
%     model = getfield(load(['models/' model_filenames{i}]), 'model_class');
%     Y_hats{i} = classRF_predict(X_tst,model);
%     disp([' predicted ' num2str(1.0 * sum(Y_hats{i}==1) / length(Y_hats{i})) ' % of test cases to be preictal']);
% end
% 
% Y_hat = Y_hats{1} + Y_hats{2} > 0
Y_hat = classRF_predict(X_tst,model_class);
disp([ num2str(100.0 * mean(Y_hat)) '% of test data predicted to be seizure']);
figure;
stem(Y_hat)
title('predictions on test data');
% err_rate = length(find(Y_hat~=Y_tst)) %number of misclassification

%%
all_files = filesInDirectories(test_directories);

i = 1;
while exist(['submissions/partial_' num2str(i) '.csv'], 'file') ~= 0
    i = i + 1;
end

fid = fopen(['submissions/partial_' num2str(i) '.csv'],'w');
j = 0;
for fname = all_files
    j = j + 1;
   fprintf( fid, [ fname{1} ',' num2str(Y_hat(j)) '\n' ] ); 
end
fclose(fid)
disp(['Saved as ' 'submissions/partial_' num2str(i) '.csv'])

