function worst_risks = worst_risk_discrete(D1, D2, D1_priors)
% worst_risks = worst_risk_discrete(D1, D2, D1_priors)
%
%   Compute worst possible risks of a bayesian strategies.
%
%   Parameters:
%       D1, D2 - discrete distributions
%       D1_priors - <1 x n> vector of D1 priors to be used
%
%   Returns:
%       worst_risks - <1 x n> worst risk of bayesian strategies
%                     for D1, D2 with different priors D1_priors


%   Hint: for all D1_priors calculate bayesian strategy and 
%   corresponding maximal risk.

W = [0 1; 1 0];
worst_risks = zeros(size(D1_priors));

distr1 = D1;
distr2 = D2;
for i = 1:length(worst_risks)
    distr1.Prior = D1_priors(i);
    distr2.Prior = 1-D1_priors(i);
    
    q = find_strategy_discrete(distr1,distr2, W);
    
    worst_risks(i) = max(risk_fix_q_discrete(distr1,distr2,D1_priors,q));
end
