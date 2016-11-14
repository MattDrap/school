% A function for learning a GMM-based classifier from trianing examples.
% Input:
%       examples ... a column vector containing the trianing examples
%       (one-dimensional)
%       labels ... a column vector containing labels of the training
%       examples
%       k ... number of components of the positive and negative model
% Output:
%       classifier ... a structure containing structures 'positive_model',
%       'negative_model' and a number 'threshold'. The structures
%       'positive_model' and 'negative_model' contain fields: 'means',
%       'stds' and 'ps' which are parameters of a Gaussian mixture model
function [classifier] = learnGMMClassifier(examples, labels, k)

positive_examples = examples(labels == 1,:);
negative_examples = examples(labels == -1, :);

[means, stds, ps] = EM(positive_examples, k);
positive_model.means = means;
positive_model.stds = stds;
positive_model.ps = ps;

[means, stds, ps] = EM(negative_examples, k);
negative_model.means = means;
negative_model.stds = stds;
negative_model.ps = ps;

classifier.positive_model = positive_model;
classifier.negative_model = negative_model;
classifier.threshold = size(negative_examples,1)/size(positive_examples,1);