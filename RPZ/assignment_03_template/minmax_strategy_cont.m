function [q, risk] = minmax_strategy_cont(D1, D2)
% [q risk] = minmax_strategy_cont(D1, D2)
%
%   Find minmax strategy.
%
%   Parameters:
%       D1, D2 - 2 normal distributions
%                D1.Sigma, D1.Mean
%                prior not needed
%
%   Returns:
%       q - strategy (see find_strategy_2normal)
%       risk - bayes risk of the minimax strategy q
D1_priors = 0:0.01:1;
function r = minimax(D1, D2, p)
    D1.Prior = p;
    D2.Prior = 1 - p;
    q = find_strategy_2normal(D1,D2);
    r = max(risk_fix_q_cont(D1,D2, D1_priors,q));
end
min = fminbnd(@(prior) minimax(D1,D2,prior), 0 ,1);
D1.Prior = min;
D2.Prior = 1 - min;
q = find_strategy_2normal(D1, D2);
risk = bayes_risk_2normal(D1, D2, q);
end