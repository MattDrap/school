% constructs bias-variance-tradeoff curves. "maxK" is the maximum number of
% literals in a conjunction, "train" is a matrix with train-set part of the
% dataset (rows ~ examples, columns ~ variables), "train_labels" is a
% vector containing labels of the training examples. Analogically, "test"
% is the matrix containing test-set examples and "test_labels" contains the
% test-set labels
function errors = conj_bias_variance(maxK, train, train_labels, test, test_labels)

errors = zeros(1, maxK);

for i = 1:maxK
    conjunction = conj_bb(i, train, train_labels);
    errors(i) = conj_error(conjunction, test, test_labels);
end