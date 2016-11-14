function [var_mean, var_sigma] = mle_variance(cardinality)
% [var_mean var_sigma] = mle_variance(cardinality)
%
%   Estimates variance of estimated parameters of a normal distribution 
%   in 100 trials.
%
%   Parameters:
%       cardinality - size of the generated dataset (e.g. 1000)
%   Returns
%       var_mean - variance of the estimated means in 100 trials
%       var_sigma - variance of the estimated standard deviation in 100 trials


    numTrials = 100;
    muRec = zeros(1,numTrials);
    sigmaRec = zeros(1,numTrials);
    for i = 1:100
        [muRec(i), sigmaRec(i)] = mle_normal(randn(1,cardinality));
    end
    muRecmean = (1/numTrials) * sum(muRec);
    sigmaRecmean = (1/numTrials) * sum(sigmaRec);
    var_mean = 1/numTrials * sum((muRec - muRecmean).^2);
    var_sigma = 1/numTrials * sum((sigmaRec - sigmaRecmean).^2);


