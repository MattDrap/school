function labels = classify_bayes_parzen(x_test, xA, xC, pA, pC, h_bestA, h_bestC)
% labels = classify_bayes_parzen(x_test, xA, xC, pA, pC, h_bestA, h_bestC)
%
%   Classifies data using bayesian classifier with densities estimated by
%   Parzen window estimator.
%
%   Parameters:
%       x_test - data (measurements) to be classified
%       xA, xC - training data for Parzen window for class A and C
%       pA, PC - prior probabilities
%       h_bestA, h_bestC - optimal values of the kernel bandwidth
%
%   Returns:
%       labels - classification labels for x_test
pxA = my_parzen(x_test, xA, h_bestA);
pxC = my_parzen(x_test, xC, h_bestC);

jointA = pxA * pA;
jointC = pxC * pC;
labels = ones(1, length(x_test));
labels(jointA < jointC) = 2;