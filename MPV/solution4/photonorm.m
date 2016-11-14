function ptsn=photonorm(pts)

   ptsn=pts;
   for i=1:numel(pts)
      ptch = ptsn(i).patch;
      ptch(isnan(ptch))=0;
      ptsn(i).mean = mean(ptch(:));
      ptsn(i).std = std(ptch(:),1);
      ptch = ptch - ptsn(i).mean;
      ptsn(i).patch = (ptch / ptsn(i).std .* 0.2)+0.5;
   end;