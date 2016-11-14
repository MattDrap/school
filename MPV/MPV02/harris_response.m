function response=harris_response(img, sigmad, sigmai)
%harris_response Harris response of image with given variances
%   Detailed explanation goes here
x = [-ceil(3.0*sigmad):ceil(3.0*sigmad)];
G = gauss(x, sigmad);
G = G./sum(G);
smoothed = conv2(G, G, img, 'same');

dx = conv2(1, [1,0, -1]/2, smoothed, 'same');
dy = conv2([1,0, -1]/2, 1, smoothed, 'same');

x = [-ceil(3.0*sigmai):ceil(3.0*sigmai)];
G = gauss(x, sigmai);
G = G./sum(G);

dx2 = conv2(G, G, dx.*dx, 'same');
dy2 = conv2(G, G, dy.*dy, 'same');
dxy = conv2(G, G, dx.*dy, 'same');

response = (dx2.*dy2-dxy.^2)-0.04*(dx2+dy2).^2; 
end

