function ptsn=photonorm(pts)

   ptsn=pts;
   for i=1:numel(pts)
      ptsn(i).mean = mean(ptsn(i).patch(:));
      ptsn(i).std = std(ptsn(i).patch(:),1);
      ptsn(i).patch = ptsn(i).patch - ptsn(i).mean;
      ptsn(i).patch = (ptsn(i).patch ./ptsn(i).std .* 0.2)+0.5;
   end;