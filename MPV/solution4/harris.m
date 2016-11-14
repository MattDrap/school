function [x,y]=harris(img, sigmad, sigmai, threshold)
   
   if (nargin<2) sigmad = 1.0; end;
   if (nargin<3) sigmai = 1.6*sigmad; end;
   if (nargin<4) threshold = 0.03^4; end;
   
   [y x] = find(nonmaxsup2d(harris_response(img,sigmad,sigmai), threshold));
   % correct for matlab indexing an get rid of invalid points
   x = x'-1; y = y'-1; [x,y]=filter_boundaries(img,x,y,sigmai);
   