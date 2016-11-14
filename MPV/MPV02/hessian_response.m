function response=hessian_response(img,sigma)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
x = [-ceil(3.0*sigma):ceil(3.0*sigma)];
G = gauss(x, sigma);
G = G./sum(G);
smoothed = conv2(G, G, img, 'same');

dx = conv2(1, [1,0, -1]/2, smoothed, 'same');

dxx = conv2(1, [1, -2, 1], smoothed, 'same');
dxy = conv2([1,0, -1]/2, 1, dx, 'same');
dyy = conv2([1, -2, 1], 1, smoothed, 'same');

response = dxx.*dyy - dxy.^2;
end

