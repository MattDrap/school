function A=getframes(pts); 
% composes frame representation from point structure, works for affine and similarity covariant points
   A=[];
   for i=1:numel(pts)
      p=pts(i);
      if (isfield(p,'a11'));        
         A(:,:,i)=[p.a11 p.a12 p.x ; p.a21 p.a22 p.y ; 0 0 1];
      else
         if (isfield(A, 's'))
            A(:,:,i)=[p.s 0 p.x ; 0 p.s p.y ; 0 0 1]*R;
         end;
      end;            
   end;
