function R = bayes_risk_discrete(distribution1, distribution2, W, q)
% Parameters:
%       distribution1.Prob      pXk(x|A) given as a 1×21 vector
%       distribution1.Prior 	prior probability pK(A)
%       W                       cost function matrix
%                               dims: <states x decisions>
%                               (nr. of states and decisions is fixed to 2)
%       q                       strategy - 1x21 vector, values 1 or 2

R = sum(distribution1.Prior * distribution1.Prob .* W(1, q(:))) + sum(distribution2.Prior * distribution2.Prob .* W(2, q(:)));

