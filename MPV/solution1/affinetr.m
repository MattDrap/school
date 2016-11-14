function [out]=affinetr(in, A, ps, ext)
   
   [x y] = meshgrid(linspace(-ext,+ext, ps), linspace(-ext,+ext, ps));   
   out = interp2(in, A(1,1)*x+A(1,2)*y+A(1,3)+1, A(2,1)*x+A(2,2)*y+A(2,3)+1);

   