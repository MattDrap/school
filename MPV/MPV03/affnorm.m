function pts=affnorm(img,x,y,a11,a12,a21,a22,opt)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
pts = struct();
for i = 1:length(x)
    A=[a11(i),a12(i) x(i) ; 
           a21(i),a22(i) y(i) ; 
           0,     0,     1];
      norm_patch = affinetr(img, A, opt.ps, opt.ext);
      angle = -dom_orientation(norm_patch);
      R = [ cos(angle) sin(angle) ; 
           -sin(angle) cos(angle)];
       
      A(1:2,1:2,:)=A(1:2,1:2,:)*R;
      % create output
      pts(i).x=x(i);
      pts(i).y=y(i);
      pts(i).a11=A(1,1);
      pts(i).a12=A(1,2);
      pts(i).a21=A(2,1);
      pts(i).a22=A(2,2);
      pts(i).patch=affinetr(img, A, opt.ps, opt.ext);
end
end

