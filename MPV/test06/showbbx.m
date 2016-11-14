function showbbx(bbx, A, ofs)

   if (nargin<3)
      ofs=[1 1];
   end;
   ptbbx = [bbx([1,3,3,1,1]);
            bbx([2,2,4,4,2])];
   ptbbx(3,:) = 1;
   ptsbbx = A * ptbbx;
   line(ptsbbx(1,:)+ofs(1), ptsbbx(2,:)+ofs(2), 'color', [0.9 0.7 0], 'linewidth', 3);
