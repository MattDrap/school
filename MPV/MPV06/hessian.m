function [x,y]=hessian(img, sigma, threshold)

   if (nargin<2) sigma = 1; end;
   if (nargin<3) threshold = 0.02; end;

   [y x] = find(nonmaxsup2d(hessian_response(img,sigma), threshold));   
   % correct for matlab indexing an get rid of invalid points
   x = x'-1; y = y'-1; [x,y]=filter_boundaries(img,x,y,sigma);
   