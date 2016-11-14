function D = dgauss(x,sigma)
D = -(x.*exp(-x.^2/(2*sigma^2)))/(sqrt(2*pi)*sigma^3);
