% generates learning curve, "learningFunction" is a handle of function with
% three input arguments "k", "examples" and "labels" (which have the same meaning as in function
% conj_bb, which is also an example of a legal function that can be used
% here), "k" is the maximum number of literals in a conjunction, train is a
% matrix form of training examples (rows ~ examples, columns ~
% propositional variables), "train_labels" are labels of the train set. The
% meaning of "test" and "test_labels" is analogical.
function lc = conj_learningCurve(learningFunction, k, train, test, train_labels, test_labels)
% number of repeats - used for averaging of the learning curves
repeats = 10;
% number of points on the learning curve to be constructed
n = 10;

% we need to set the seed so that the individual learning curves produced
% by this function would be comparable.
errors = zeros(1, n);
rand('seed', 1);

for i = 1:n
    train_size = floor((i/n)*size(train,1));
    errs = [];
    for j = 1:repeats
        rp = randperm(size(train,1));
        permuted_train = train(rp,:);
        permuted_train_labels = train_labels(rp);
        subsampled_train = permuted_train(1:train_size,:);
        subsampled_train_labels = permuted_train_labels(1:train_size);
        conjunction = learningFunction(k, subsampled_train, subsampled_train_labels);
        errs = [errs conj_error(conjunction, test, test_labels)];
    end
    errors(i) = mean(errs)
end

lc = errors;