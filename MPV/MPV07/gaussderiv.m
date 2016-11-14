function [gx, gy] = gaussderiv(in, sigma)   
   % faster version of gaussian derivatives
   out = gaussfilter(in, sigma);
   gx = conv2(1, [1 0 -1]/2, out, 'same');
   gy = conv2([1 0 -1]/2, 1, out, 'same');
