% A function for visualizing classifier decisions
% Input:
%       classifier ... a structure containing structures 'positive_model',
%       'negative_model' and a number 'threshold'. The structures
%       'positive_model' and 'negative_model' contain fields: 'means',
%       'stds' and 'ps' which are parameters of a Gaussian mixture model
%       xs ... grid of the x-axis for which we want to display the
%       decisions
function [fig] = visualize_classifier(classifier, xs)

pos_dens = zeros(1,size(xs,1));
neg_dens = zeros(1,size(xs,1));
for i = 1:size(xs,1)
    pos_dens(i) = density(xs(i), classifier.positive_model.means, classifier.positive_model.stds, classifier.positive_model.ps);
    neg_dens(i) = density(xs(i), classifier.negative_model.means, classifier.negative_model.stds, classifier.negative_model.ps);
end

positive_regions = {[]};
negative_regions = {[]};
predictions =  classify(classifier, xs);
for i = 1:(size(xs,1)-1)
    if predictions(i) == predictions(i+1)
       if predictions(i) == 1
           positive_regions{end} = [positive_regions{end} xs(i)];
       else
           negative_regions{end} = [negative_regions{end} xs(i)];
       end
    else
        if predictions(i) == 1
            positive_regions{end} = [positive_regions{end} xs(i)];
            negative_regions{end+1} = [];
        else
            negative_regions{end} = [negative_regions{end} xs(i)];
            positive_regions{end+1} = [];
        end
    end
end

fig = figure;
hold on;
plot(xs', pos_dens/(1+classifier.threshold), 'b');
plot(xs', neg_dens*(1-1/(1+classifier.threshold)), 'r');

for i = 1:length(positive_regions)
    plot(positive_regions{i}, zeros(1,length(positive_regions{i})), 'b', 'LineWidth', 6);
end

for i = 1:length(negative_regions)
    plot(negative_regions{i}, zeros(1,length(negative_regions{i})), 'r', 'LineWidth', 6);
end