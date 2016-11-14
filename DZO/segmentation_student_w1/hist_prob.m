function prob = hist_prob(x, pdf)
% Compute probabilities of input data in the discrete distribution.
%
% Input:
%   x [1xN (double)] N input data values; each value is from the set
%     linspace(0, 1, M) = [0, 1/(M-1), 2/(M-1), ..., (M-2)/(M-1), 1]
%   pdf [1xM (double)] PDF of the discrete distribution of M values
%     linspace(0, 1, M)
%
% Output:
%   prob [1xN (double)] probabilities of N input values in the discrete
%     distribution specified by the given PDF

% TODO: Replace with your own implementation.
b = linspace(0,1, size(pdf, 2));
prob = zeros(1, size(x, 2));
for i = 1:size(x, 2)
    ind = abs(x(i) - b) < 0.0001;
    prob(i) = pdf(ind);
end

end
