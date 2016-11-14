function mi = mutual_information(im1, im2) 
% function mi = mutual_information(im1, im2) 
% Computes mutual information of intensity pairs.
% (im1 and im2 thus must have the same size). 
    
% IMPLEMENT computation of MI. Remove the following line:
mi = 1;
bins = linspace(0, 1, 10);
h1 = hist(im1(:), bins);
h2 = hist(im2(:), bins);
p1 = h1./sum(h1);
p2 = h2./sum(h2);
E1 = -sum(p1(p1 > 0) .* log(p1(p1>0)));
E2 = -sum(p2(p2 > 0) .* log(p2(p2 > 0)));

h3 = hist3([im1(:),im2(:)], [{bins}, {bins}]);

p3 = h3./sum(sum(h3));
E3 = -sum(p3(p3 > 0) .* log(p3(p3 > 0)));

mi = E1 + E2 - E3;
    


% finally, invert it because we use minimization framework: 
mi = -mi; 

