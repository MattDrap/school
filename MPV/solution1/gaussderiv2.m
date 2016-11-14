function [gxx, gxy, gyy] = gaussderiv2_s(in, sigma)
   % slower version of second order gaussian derivatives
      x = gausscutoff(sigma);
      G = gauss(x, sigma); D = dgauss(x, sigma); DD = ddgauss(x, sigma);
      
      gxx = conv2(G, DD, in, 'same');
      gxy = conv2(D, D, in, 'same');
      gyy = conv2(DD, G, in, 'same');