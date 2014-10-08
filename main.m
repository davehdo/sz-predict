clear

%%

subjects = struct;

subjects(1).preictal_dir = 'data/Dog_1/training_1';
subjects(1).interictal_dir = 'data/Dog_1/training_0';

subjects(2).preictal_dir = 'data/Dog_2/training_1';
subjects(2).interictal_dir = 'data/Dog_2/training_0';

subjects(3).preictal_dir = 'data/Dog_3/training_1';
subjects(3).interictal_dir = 'data/Dog_3/training_0';

subjects(4).preictal_dir = 'data/Dog_4/training_1';
subjects(4).interictal_dir = 'data/Dog_4/training_0';

subjects(5).preictal_dir = 'data/Dog_5/training_1';
subjects(5).interictal_dir = 'data/Dog_5/training_0';

test_directories = {
     'data/Dog_1/testing';
     'data/Dog_2/testing';
     'data/Dog_3/testing';
     'data/Dog_4/testing';
     'data/Dog_5/testing';
};

%% Extract features for the training set
for i = 1:length(subjects);
    disp(['Loading training data for subject ' num2str(i) ' ' subjects(i).preictal_dir]);
    subjects(i).preictal_features = extractFeaturesFromFiles( filesInDirectories({subjects(i).preictal_dir}) );
    subjects(i).preictal_learning_signal = ones(1, size(subjects(i).preictal_features, 2));

    subjects(i).interictal_features = extractFeaturesFromFiles( filesInDirectories({subjects(i).interictal_dir}) );
    subjects(i).interictal_learning_signal = zeros(1, size(subjects(i).interictal_features, 2));
end
disp(['Done loading the training data']);

% plot population characteristics
figure;
for i = 1:length(subjects);
    subplot( length(subjects), 1, i );
    plotPopulationCharacteristics( subjects(i).preictal_features, subjects(i).interictal_features );
end

%% Concatenate all the data, divide into training and test sets, and run validation
percent_used_for_training = 90;

for i = 1:length(subjects);
    concat_features = [subjects(i).preictal_features subjects(i).interictal_features];
    concat_learning_signal = [subjects(i).preictal_learning_signal subjects(i).interictal_learning_signal];

    indexes_for_training = rand(1, size(concat_features,2) ) < percent_used_for_training / 100.0;

    disp(['Training model for subject ' num2str(i) ' using ' num2str(percent_used_for_training) '% of data (' num2str(sum(indexes_for_training)) ' of ' num2str(length(indexes_for_training)) ')...']);

    % dividing up into training and testing
    subjects(i).training_features = concat_features(:, indexes_for_training);
    subjects(i).training_learning_signal = concat_learning_signal(:, indexes_for_training);

    subjects(i).validation_features = concat_features(:, indexes_for_training == 0);
    subjects(i).validation_learning_signal = concat_learning_signal(:, indexes_for_training == 0);

    % train the random forest model and test on known test set
    % classification: 

    subjects(i).model = classRF_train(subjects(i).training_features', subjects(i).training_learning_signal', 1000,3);
 

    Y_tst = subjects(i).validation_learning_signal';
    Y_hat = classRF_predict(subjects(i).validation_features', subjects(i).model);
    subjects(i).testing_predictions = Y_hat;
    
    subjects(i).testing_err_rate = length(find(Y_hat~=Y_tst)) / length(Y_hat); %number of misclassification

    disp([' Training complete. Error rate ' num2str(subjects(i).testing_err_rate)]);
    disp(' ');
    clear indexes_for_training concat_features concat_learning_signal Y_hat Y_tst
end

%% Save the model
% creates the directory
if exist('models', 'file') == 0
   mkdir('models'); 
end

% look for next available serial number
i = 1;
while exist(['models/models_' num2str(i) '.mat'], 'file') ~= 0
    i = i + 1;
end
% model_class.serial = ['models_' num2str(i)];
save(['models/models_' num2str(i) '.mat'], 'subjects');
disp(['Saved as models/models_' num2str(i) '.mat']);

%% Train the patient_id classifier
concat_features = [];
concat_learning_signal = [];

for i = 1:length(subjects);
    n_clips = size(  subjects(i).preictal_features, 2) + size( subjects(i).interictal_features, 2);
    concat_features = [concat_features, subjects(i).preictal_features, subjects(i).interictal_features];
    concat_learning_signal = [concat_learning_signal, i*ones(1, n_clips)];
    clear n_clips

end

indexes_for_training = rand(1, size(concat_features,2) ) < percent_used_for_training / 100.0;

disp(['Using ' num2str(percent_used_for_training) '% for training which_dog_model(' num2str(sum(indexes_for_training)) ' of ' num2str(length(indexes_for_training)) ')...']);

training_features = concat_features(:, indexes_for_training);
training_learning_signal = concat_learning_signal(:, indexes_for_training);

testing_features = concat_features(:, indexes_for_training == 0);
testing_learning_signal = concat_learning_signal(:, indexes_for_training == 0);

clear concat_features concat_learning_signal indexes_for_training

% train the random forest model and test on known test set
% classification: 
X_trn = training_features';
Y_trn = training_learning_signal';
which_dog_model = classRF_train(X_trn,Y_trn,1000,3);
disp(' Training complete');

clear training_features training_learning_signal;

X_tst = testing_features';
Y_tst = testing_learning_signal';
Y_hat = classRF_predict(X_tst,which_dog_model);

clear testing_features testing_learning_signal;

which_dog_err_rate = length(find(Y_hat~=Y_tst)) / length(Y_hat); %number of misclassification

disp([' Error rate ' num2str(which_dog_err_rate)]);

%% Load and test the test set
result=input('Use cached test set features? (Do this if feature extraction algorithm has not changed) y/n ','s');

if result == 'n'
    disp('re-extracting features from the test data set');
    test_files = filesInDirectories(test_directories);
    test_features = extractFeaturesFromFiles( test_files );
    X_tst = test_features';

    save(['features_from_test_set.mat'], 'X_tst');
else
    disp('loaded cached features from last time');
    load('features_from_test_set.mat');
    % X_tst will be assigned by the 'load' call above
end

disp('Done. Test data are loaded and ready to run predictions');

% Run the predictions on which subject test data belongs to and plot them

predicted_subject = classRF_predict(X_tst,which_dog_model);

figure;
stem(predicted_subject);
title('predict which subject each entry belongs to');
% err_rate = length(find(Y_hat~=Y_tst)) %number of misclassification

%% Go through each subject and run predictions on which ones are preictal 

% create an empty array
predicted_preictal = -1 * ones( size(X_tst,1), 1); % many x 1 array

figure;

for i = 1:length(subjects);
    test_entry_ids = find(predicted_subject == i);
    predicted_preictal(test_entry_ids) = classRF_predict( X_tst( test_entry_ids, : ), subjects(i).model);
    disp(['Subject ' num2str(i) ': ' num2str( 100.0 * mean(predicted_preictal(test_entry_ids)) ) '% predicted to be preictal']);
    hold on
    bar( i, 100.0 * mean(predicted_preictal(test_entry_ids)));
    hold off
end

% stem(predicted_preictal) % many x 1 array
title('Predict which ones are preictal (each should be near 50%)');
hold on;
plot( 1:length(subjects), 50.0 * ones(1, length(subjects)), 'r' );
hold off;
disp([ num2str(100.0 * mean(predicted_preictal)) '% of test data predicted to be seizure']);
xlabel('Subject');
ylabel('Percent predicted to be preictal');

%% Save the predictions to a CSV

test_files = filesInDirectories(test_directories); % 2 x many array

output = horzcat(test_files(1,:)', num2cell(predicted_preictal) ); % many x 2 array

% model_class.serial; % this should exist. this line will trigger exception if not

i = 1;
while exist(['submissions/partial_' num2str(i) '.csv'], 'file') ~= 0
    i = i + 1;
end

fid = fopen(['submissions/partial_' num2str(i) '.csv'],'w');
j = 0;
% fprintf( fid, ['Model: ' model_class.serial '\n']);
for row = output'
   fprintf( fid, [ row{1} ',' num2str(row{2}) '\n' ] ); 
end
fclose(fid);
disp(['Saved as ' 'submissions/partial_' num2str(i) '.csv']);

