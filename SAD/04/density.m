% Computes density at point x for a GMM model with parameters means, stds
% and ps (means, standard deviations and prior probabilities of the mixture components)
function d = density(x, means, stds, ps)
d = 0;
for i = 1:size(means,1)
    d = d + normpdf(x, means(i), stds(i))*ps(i);
end