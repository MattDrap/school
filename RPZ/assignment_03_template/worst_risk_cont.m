function worst_risks = worst_risk_cont(D1, D2, D1_priors)
% worst_risks = worst_risk_cont(D1, D2, D1_priors)
%
%   Compute worst possible risks of a bayesian strategies.
%
%   Parameters:
%       D1, D2 - normal distributions
%       D1_priors - <1 x n> vector of D1 priors to be used
%
%   Returns:
%       worst_risks - <1 x n> worst risk of bayesian strategies
%                     for D1, D2 with different priors D1_priors


%   Hint: for all D1_priors calculate bayesian strategy and 
%   corresponding maximal risk.
worst_risks = zeros(size(D1_priors));

for i = 1:length(worst_risks)
    D1.Prior = D1_priors(i);
    D2.Prior = 1-D1_priors(i);
    
    q = find_strategy_2normal(D1,D2);
    worst_risks(i) = max(risk_fix_q_cont(D1,D2, D1_priors,q));
end
