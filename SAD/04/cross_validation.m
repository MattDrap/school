% A method for estimating error of GMM-model-based classifier. It uses
% 5-fold stratified cross-validation to estimate the error
function [e] = cross_validation(examples, labels, k)

% number of folds
num_folds = 5;
% shuffling the input data in case they were ordered
p = randperm(size(examples,1));
examples = examples(p,:);
labels = labels(p);

% Since we will be performing STRATIFIED cross-validation we need to ensure
% that the proportion of positive and negative examples in all folds will
% be approximately the same
pos_examples = examples(labels == 1,:);
neg_examples = examples(labels == -1,:);

num_pos_examples = size(pos_examples,1);
num_neg_examples = size(neg_examples,1);

% We store the examples in folds and their labels in a cell array.
% The i-th element of the cell array folds is a column-vector with the examples
% (which are one-dimensional in this simple case) in the i-th fold.
folds = {};
% The i-th element of the cell array folds_labels is a column-vector
% containing labels of the examples in the i-th fold.
folds_labels = {};

% Here, we build the folds
for i = 1:num_folds
    num_pos = floor(num_pos_examples/num_folds) + (i < mod(num_pos_examples, num_folds));
    num_neg = floor(num_neg_examples/num_folds) + (i < mod(num_neg_examples, num_folds));
    p = pos_examples((1+(i-1)*floor(num_pos_examples/num_folds)):((i-1)*floor(num_pos_examples/num_folds)+num_pos),:);
    n = neg_examples((1+(i-1)*floor(num_neg_examples/num_folds)):((i-1)*floor(num_neg_examples/num_folds)+num_neg),:);
    folds{i} = [p; n];
    folds_labels{i} = [ones(num_pos,1); -ones(num_neg,1)];
end

%
% TODO
%
% This is where the error should be estimated by cross-validation and 
% stored in the variable e. This should be done by students.
% The functions that can be used to implement this are 'learnGMMClassifier'
% and 'classify'.
err = zeros(num_folds, 1);
for i =1:num_folds
    classifier = learnGMMClassifier(folds{i}, folds_labels{i}, k);
    test_fold = vertcat(folds{[1:i-1 i+1:num_folds]});
    test_lab = vertcat(folds_labels{[1:i-1 i+1:num_folds]});
    predictions = classify(classifier, test_fold);
    err(i) = mean(test_lab ~= predictions);
end
e = mean(err);

