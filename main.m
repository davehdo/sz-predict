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

test_directories = {
    'data/Dog_1/testing';
    'data/Dog_2/testing';
    'data/Dog_5/testing';
};

preictal_features = extractFeaturesFromFiles( filesInDirectories(preictal_directories) );
preictal_learning_signal = ones(1, size(preictal_features, 2));

interictal_features = extractFeaturesFromFiles( filesInDirectories(interictal_directories) );
interictal_learning_signal = zeros(1, size(interictal_features, 2));

%% concatenate all the data
concat_features = [preictal_features interictal_features];
concat_learning_signal = [preictal_learning_signal interictal_learning_signal];

%% train the random forest model
% classification: 
X_trn = concat_features';
Y_trn = concat_learning_signal';
disp('Training');
model_class = classRF_train(X_trn,Y_trn);
disp('Training complete');

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

%% Test the training set (just to see if everything worked)
X_tst = concat_features';
Y_tst = concat_learning_signal';
Y_hat = classRF_predict(X_tst,model_class);

err_rate = length(find(Y_hat~=Y_tst)); %number of misclassification

disp(['number of misclassifications ' num2str(err_rate)]);

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

