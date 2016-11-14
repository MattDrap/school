function [hes,sigma]=sshessian_response(img)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
levels = 40;
step = 1.1;
[ss, sigma] = scalespace(img, levels, step);
hes = zeros(size(ss));
for i = 1:levels
    dx = conv2(1, [1,0, -1]/2, ss(:,:,i), 'same');

    dxx = conv2(1, [1, -2, 1], ss(:,:,i), 'same');
    dxy = conv2([1,0, -1]/2, 1, dx, 'same');
    dyy = conv2([1, -2, 1], 1, ss(:,:,i), 'same');
    hes(:,:,i) = sigma(i)^4*(dxx.*dyy - dxy.^2);
end
end

