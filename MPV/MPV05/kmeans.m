function [means, err]=kmeans(K, data)
%kmeans Compute kmeans for data and K
%   Detailed explanation goes here
id_means = randi([1, size(data, 2)], 1, K);
means = data(:, id_means);
old_classes = zeros(1, size(data, 2));
classes = ones(1, size(data, 2));
while sum(old_classes - classes) ~= 0
    old_classes = classes;
    [in, dists] = nearest(means, data);
    classes = in;
    
    for i = 1:K
        if isempty(data(:, in == i))
            means(:, i) = data(:, randi([1, size(data, 2)], 1, 1));
        else
            means(:, i) = mean(data(:, in == i), 2);
        end
    end
end
err = sum(dists);
end

