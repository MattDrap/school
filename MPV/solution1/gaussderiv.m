function [gx, gy] = gaussderiv_s(in, sigma)
   % slower version of gaussian derivatives
   x = gausscutoff(sigma);
   D = dgauss(x, sigma); G = gauss(x, sigma);
   
   gx = conv2(G, D, in, 'same');
   gy = conv2(D, G, in, 'same');
   