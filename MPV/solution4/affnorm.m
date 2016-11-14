function pts=affnorm(img,x,y,a11,a12,a21,a22,opt)
   
   pts = struct('x', num2cell(x), 'y', num2cell(y));
   for i=1:numel(pts)
      A=[a11(i) a12(i) x(i) ; 
         a21(i) a22(i) y(i) ; 
         0 0 1];
      tmp = affinetr(img, A, opt.ps, opt.ext);
      angle = -dom_orientation(tmp);
      R = [ cos(angle) sin(angle) ; 
           -sin(angle) cos(angle)];
      A(1:2,1:2,:)=A(1:2,1:2,:)*R;
      pts(i).a11 = A(1,1);  pts(i).a12 = A(1,2);
      pts(i).a21 = A(2,1);  pts(i).a22 = A(2,2);
      pts(i).patch = affinetr(img, A, opt.ps, opt.ext);
   end;