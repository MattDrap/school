function [ err ] = calcErrReprojection(u_orig, u_reproj)
%calcErrReprojection ||u_orig - u_reproj||_2 ^2
%   Detailed explanation goes here

err = sum((u_reproj - u_orig).^2);
end

