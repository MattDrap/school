% Function for classifying 'examples'
% Input:
%       classifier ... a structure containing structures 'positive_model',
%       'negative_model' and a number 'threshold'. The structures
%       'positive_model' and 'negative_model' contain fields: 'means',
%       'stds' and 'ps' which are parameters of a Gaussian mixture model
% Output: 
%       a column-vector containing predicted class-labels (1 or -1)

function [predictions] = classify(classifier, examples)

predictions = zeros(size(examples,1),1);
for i = 1:size(examples,1)
    likelihood_ratio = density(examples(i,:), classifier.positive_model.means, classifier.positive_model.stds, classifier.positive_model.ps)/...
        density(examples(i,:), classifier.negative_model.means, classifier.negative_model.stds, classifier.negative_model.ps);
    if likelihood_ratio >= classifier.threshold
        predictions(i) = 1;
    else
        predictions(i) = -1;
    end
end

