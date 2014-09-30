clear

%% Load and clip the files
preictal_directories = {
    'data/Dog_1/training_1';
    'data/Dog_5/training_1';
};

interictal_directories = {
    'data/Dog_1/training_0';
    'data/Dog_5/training_0';
};

test_directories = {
    'data/Dog_1/testing';
    'data/Dog_5/testing';
};

preictal_features = extractFeaturesFromDirectories( preictal_directories );
preictal_learning_signal = ones(1, size(preictal_features, 2));

interictal_features = extractFeaturesFromDirectories( interictal_directories );
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
test_features = extractFeaturesFromDirectories(test_directories);

X_tst = test_features';
% Y_tst = Y_trn;
Y_hat = classRF_predict(X_tst,model_class);

figure;
stem(Y_hat)
title('predictions on test data');
% err_rate = length(find(Y_hat~=Y_tst)) %number of misclassification

%%
all_files = filesInDirectories(test_directories);
for i = 1:size(all_files,2)
   disp( [ all_files{i} ',' num2str(Y_hat(i)) ] ); 
end