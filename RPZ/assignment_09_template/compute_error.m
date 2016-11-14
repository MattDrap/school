function errors = compute_error(strong_class, X, y)
% errors = compute_error(strong_class, X, y)
%
% Computes the error on data X for *all lengths* of the given strong
% classifier
%
%   Parameters:
%       strong_class - the structure returned by adaboost()
%
%       X [K x N] - samples, K is the number of weak classifiers and N the
%            number of data points
%
%       y [1 x N] - sample labels (-1 or 1)
%
%   Returns:
%       errors [1 x T] - error of the strong classifier for all lenghts 1:T
%            of the strong classifier
%
Hn = size(strong_class.wc, 2);
Res = zeros(1, length(y));
errors = zeros(1, Hn);
for i = 1:Hn
    Res = Res + sign(strong_class.wc(i).parity * (X(strong_class.wc(i).idx, :) - strong_class.wc(i).theta)).* strong_class.alpha(i);
    errors(i) = sum(sign(Res) ~= y)/length(y);
end