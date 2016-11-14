close all;
% number of examples used for training
train_size = 100;%100;
% number of mixture components in positive and negative models
k = 4;
% generating the training and testing examples
% The examples are drawn from mixtures of k gaussians. The positive
% examples are drawn from a mixture with standard deviation equal to one
% and means = [2 4 6 ... 2*k]. The negative examples are drawn from a 
% mixture with standard deviation equal to 0.5 and means = [1 3 4 ... 2*k-1].
[dataset, labels] = generate_examples(10000, k);

% we need to shuffle the dataset 
rp = randperm(size(dataset,1));
dataset = dataset(rp,:);
labels = labels(rp);

% these will be our training examples
train_examples = dataset(1:train_size,:);
train_labels = labels(1:train_size);

% ... and these will be our testing examples
test_examples = dataset(train_size:end,:);
test_labels = labels(train_size:end);

%% Visualizing the complete dataset
figure;
title('Complete Dataset');
hold on;
[h_pos, c_pos] = hist(dataset(labels == 1), 30);
[h_neg, c_neg] = hist(dataset(labels == -1), 30);
bar(c_pos, h_pos, 'FaceColor', 'b');
bar(c_neg, h_neg, 'FaceColor', 'r');

%% Visualizing the training data
figure;
title('Training Data');
hold on;
[h_pos, c_pos] = hist(train_examples(train_labels == 1), 30);
[h_neg, c_neg] = hist(train_examples(train_labels == -1), 30);
bar(c_pos, h_pos, 'FaceColor', 'b');
bar(c_neg, h_neg, 'FaceColor', 'r');

%% Model learning with "known" k
% Here, we learn a classification model using EM algorithm with the known k
% for learning a model for positive data and a model for negative data

model_k = k;
classifier = learnGMMClassifier(train_examples, train_labels, model_k);
predictions = classify(classifier, test_examples);
fprintf('Test-set error: %d (using the k with which we generated the data)\n', mean(predictions ~= test_labels));

% Plotting the learned GMMs

learned_fig = visualize_classifier(classifier, (-1:0.01:(2*k+1))');
title('Classifier 1 - using the k with which we generated the data');
plot(train_examples(train_labels == 1), zeros(1,sum(train_labels == 1)), 'b*', 'MarkerSize', 10);
plot(train_examples(train_labels == -1), zeros(1,sum(train_labels == -1)), 'ro', 'MarkerSize', 10);

%% Selecting the optimal k using error estimated using 10-fold cross-validation
% Finally, here, we use k which minimizes classification error estimated by
% 10-fold cross-validation

selected_k_2 = 0;
bestError = inf;
for i = 1:10
    e = cross_validation(train_examples, train_labels, i);
    if e < bestError
        selected_k_2 = i;
        bestError = e;
    end
end
classifier = learnGMMClassifier(train_examples, train_labels, selected_k_2);
predictions = classify(classifier, test_examples);
fprintf('Test-set error: %d, Selected k: %d (parameter selection method: cross-validation)\n', mean(predictions ~= test_labels), selected_k_2);

learned_fig = visualize_classifier(classifier, (-1:0.01:(2*k+1))');
title(sprintf('Classifier %d - parameter selection method: cross-validation', selected_k_2));
plot(train_examples(train_labels == 1), zeros(1,sum(train_labels == 1)), 'b*', 'MarkerSize', 10);
plot(train_examples(train_labels == -1), zeros(1,sum(train_labels == -1)), 'ro', 'MarkerSize', 10);
