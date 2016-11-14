% A function for generating data from the following model: The examples are
% drawn from mixtures of k gaussians. The positive examples are drawn from 
% a mixture with standard deviation equal to one and means = [2 4 6 ... 2*k]. 
% The negative examples are drawn from a mixture with standard deviation 
% equal to one and means = [1 3 4 ... 2*k-1].
function [examples labels] = generate_examples(num_examples, k)

means = 1:(2*k);
stds = ones(1,2*k)/2;

labels = [];
examples = [];

for i = 1:(2*k)
    count = floor(num_examples/(2*k)) + (i < mod(num_examples, 2*k));
    if mod(i, 2) == 0
        labels = [labels; ones(count,1)];
    else
        labels = [labels; -ones(count,1)];
    end
    examples = [examples; randn(count,1)*stds(i)+means(i)]; 
end