function q = find_strategy_discrete(distribution1, distribution2, W)
% Finds bayesian strategy for 2 discrete distributions.
%
%   q = find_strategy_discrete(distribution1, distribution2, W)
%   parameters:
%       distribution1.Prob      pXk(x|A) given as a 1×21 vector
%       distribution1.Prior 	prior probability pK(A)
%       W cost function matrix - dims: <states x decisions>
%                                (nr. of states is fixed to 2)
%
%   returns: q <1x21>

[m, q] = min(bsxfun(@times,repmat(distribution1.Prior * distribution1.Prob, 2, 1),W(1, :)')...
    + bsxfun(@times, repmat(distribution2.Prior * distribution2.Prob,2,1), W(2, :)'));

