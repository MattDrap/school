function xNew = track_correspond(imgPrev,imgNew,xPrev,options)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[x,y]=harris(imgNew, options.sigmad, options.sigmai, options.threshold);
pts = transnorm(imgNew, x, y, 25, options);
    
pts = photonorm(pts);
for i=1:numel(pts)
    pts(i).desc = dctdesc(pts(i).patch, options.num_coeffs);
end

pts1 = xPrev.data;
pts2 = pts;
mat_dist=zeros(numel(pts1), numel(pts2));
right_mega_vec = [pts2.desc];

for i=1:numel(pts1)
    dist_eul = sqrt((repmat(xPrev.x(i), 1, numel(pts2)) - x).^2 + (repmat(xPrev.y(i), 1, numel(pts2)) - y).^2);
    mat_dist(i,:) = sqrt(sum((repmat(pts1(i).desc, 1, numel(pts2)) - right_mega_vec).^2));
    mat_dist(i, :) = mat_dist(i, :) + dist_eul;
end;
max_l_t=min(numel(pts1),numel(pts2));
stable_corr_counter=1;
for k=1:max_l_t
  [val, index]= min(mat_dist(:));
  [i, j]= ind2sub(size(mat_dist),index);
  corrs(:,stable_corr_counter)= [i;j];
  stable_corr_counter = stable_corr_counter + 1;             
  mat_dist(i,:)=inf; mat_dist(:,j)=inf;
end


xNew.x = x(corrs(2,:))';
xNew.y = y(corrs(2,:))';
xNew.ID = (corrs(1, :))';
xNew.data = pts(corrs(2, :));
end

