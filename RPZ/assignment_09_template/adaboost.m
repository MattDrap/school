function [strong_class, wc_error, upper_bound] = adaboost(X, y, num_steps)
% [strong_class, wc_error, upper_bound] = adaboost(X, y, num_steps)
%
% Trains an AdaBoost classifier
%
%   Parameters:
%       X [K x N] - training samples, KxN matrix, where K is the number of 
%            weak classifiers and N the number of data points
%
%       y [1 x N] - training samples labels (1xN vector, contains -1 or 1)
%
%       num_steps - number of iterations
%
%   Returns:
%       strong_class - a structure containing the found strong classifier
%           .wc [1 x num_steps] - an array containing the weak classifiers
%                  (their structure is described in findbestweak())
%           .alpha [1 x num_steps] - weak classifier coefficients
%
%       wc_error [1 x num_steps] - error of the best weak classifier in
%             each iteration
%
%       upper_bound [ 1 x num_steps] - upper bound on the training error
%

%% initialisation
N = length(y);

% prepare empty arrays for results
strong_class.wc = [];
strong_class.alpha = zeros(1, num_steps);

wc_error =  [];

%% AdaBoost
%weird init 
D = ones(1, N);
D(y == 1) = 0.5/sum(y == 1);
D(y == -1) = 0.5/sum(y==-1);

for t = 1:num_steps
    disp(['Step ' num2str(t)]);
    [h, wc_e] = findbestweak(X, y, D);
    if t == 1
       wc_e = wc_e / sum(D);
       D = D ./ sum(D);
    end
    wc_error(t) = wc_e;
    if wc_e >= 0.5
        break;
    end
    strong_class.wc = [strong_class.wc, h];
    alph = 0.5*log((1 - wc_e)/wc_e);
    strong_class.alpha(t) = alph;
    w_classif = y .* sign(h.parity .* (X(h.idx, :) - h.theta));
    D = D .* (sqrt(wc_e./(1-wc_e)).^(w_classif));
    
    %D = D.*exp(-alph.*y.*sign(h.parity .* (X(h.idx, :) - h.theta)));
    
    Z(t) = sum(D);
    D = D./sum(D);    
end
upper_bound = cumprod(Z);

