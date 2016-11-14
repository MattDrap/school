function [out] = gaussfilter(in, sigma)   
   x = gausscutoff(sigma);
   G = gauss(x, sigma);
   G = G/sum(G);
   out = conv2(G, G, in, 'same');   
