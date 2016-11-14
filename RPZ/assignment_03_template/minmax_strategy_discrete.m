function [q risk] = minmax_strategy_discrete(D1, D2)
% [q risk] = minmax_strategy_cont(D1, D2)
%
%   Find minmax strategy.
%
%   Parameters:
%       D1, D2 - 2 discrete distributions
%                D1.Prob - <1x21> vector of conditional probs
%                prior not needed
%
%   Returns:
%       q - strategy, <1x21> vector of 1 and 2 (see find_strategy_discrete)
%       risk - bayes risk of the minimax strategy q (in discrete
%       case, use the worse case risk of the optimal strategy - do
%       you know why?)

W = [0 1; 1 0];
Priors = 0:0.01:1;
function r = minimax(D1, D2, p)
    D1.Prior = p;
    D2.Prior = 1 - p;
    q = find_strategy_discrete(D1,D2,W);
    r = max(risk_fix_q_discrete(D1,D2,Priors,q));
end
min = fminbnd(@(prior) minimax(D1,D2,prior), 0 ,1);
D1.Prior = min;
D2.Prior = 1 - min;
q = find_strategy_discrete(D1, D2, W);
risk = bayes_risk_discrete(D1, D2, W, q);
end

