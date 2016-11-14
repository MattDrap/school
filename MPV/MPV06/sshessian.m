function [x,y,s]=sshessian(img, threshold)

   if (nargin<2) threshold = 0.02; end;
   
   [hes sigma]=sshessian_response(img);
   nms = nonmaxsup3d(hes, threshold);
   [y x s] = ind2sub(size(nms), find(nms));

   % get real scales and correct for matlab indexing, throw away junk
   s = sigma(s); x = x'-1; y = y'-1; [x,y,s]=filter_boundaries(img,x,y,s);