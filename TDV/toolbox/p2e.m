function [ u_e ] = p2e( u_p )
%p2e Summary of this function goes here
%   Detailed explanation goes here
u_e = bsxfun(@rdivide, u_p, u_p(end, :));
u_e = u_e(1:end - 1 , :);
end

