function [ mu, kov ] = mle_normalBi(x)
    N = length(x);
    mu = 1/N * sum(x,2);
    inter = x - repmat(mu,1,N);
    kov = 1/N *(inter*inter');
end

