function idxs=ptsinbbx(qgeom, bbx)
   idxs = qgeom(1,:)>=bbx(1) & qgeom(1,:)<=bbx(3) & ...
          qgeom(2,:)>=bbx(2) & qgeom(2,:)<=bbx(4);