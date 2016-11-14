function [nu1, nu2] = u_correct_sampson( F, u1, u2 )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

t = F' * u2;
t2 = F * u1;

e1 = zeros(1, size(u2, 2));
for j = 1:size(u1, 2)
    e1(j) = u2(:, j)' * F * u1(:,j);
end
e = err_F_sampson(F, u1, u2) ./ e1;
err = bsxfun(@times, e, [t(1:2, :); t2(1:2, :)] );
nu = [u1(1:2, :); u2(1:2, :)] - err;
nu1 = e2p(nu(1:2, :));
nu2 = e2p(nu(3:4, :));
end

