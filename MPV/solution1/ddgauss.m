function D = ddgauss(x,sigma)
D = (x.^2-sigma^2).*exp(-x.^2/(2*sigma^2))/(sqrt(2*pi)*sigma^5);
