function ptsn=photonorm(pts)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
ptsn=pts;
for i=1:length(pts)
  ptsn(i).mean = mean(ptsn(i).patch(:));
  ptsn(i).std = std(ptsn(i).patch(:));
  ptsn(i).patch = ptsn(i).patch - ptsn(i).mean;
  ptsn(i).patch = ptsn(i).patch ./ ptsn(i).std;
  ptsn(i).patch = ptsn(i).patch .* 0.2;
  ptsn(i).patch = ptsn(i).patch + 0.5;
  ptsn(i).patch(ptsn(i).patch > 1) = 1;
  ptsn(i).patch(ptsn(i).patch < 0) = 0;
end;

