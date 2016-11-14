function error = classification_error_discrete(data, labels, q)
% parameters:
%       data    <1 x n> vector
%       labels  <1 x n> vector of values 1 or 2
%       q       <1×21> vector of 1 or 2
% returns:  classification error as a fraction of false samples (e.g. 0.12)

error = sum(labels ~= classify_discrete(data, q))/length(labels)

