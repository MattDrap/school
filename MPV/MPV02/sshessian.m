function [x,y,s]=sshessian(img, thresh)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
[response, sigmas] = sshessian_response(img);
maximg=nonmaxsup3d(response, thresh);
% find positions
[y, x, u]=ind2sub(size(maximg), find(maximg)); 
% change coordinates system to zero-based
x=x'-1; y=y'-1;
s = sigmas(u);
end

