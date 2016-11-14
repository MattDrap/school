function [gxx, gxy, gyy] = gaussderiv2(in, sigma)
   % faster version of second order gaussian derivatives
   out = gaussfilter(in, sigma);
   gx = conv2(1, [1 0 -1]/2, out, 'same');
   
   gxx = conv2(1, [1 -2 1], out, 'same');
   gxy = conv2([1 0 -1]/2, 1, gx, 'same');
   gyy = conv2([1 -2 1], 1, out, 'same');
  