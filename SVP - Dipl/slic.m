function [ C, l ,d ] = slic( im, k, sig )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

nItr = 3;

[rows, cols, chan] = size(im);

px=ceil(sqrt(k*cols/rows));
if(floor(px*rows/cols)*px<k)  %does not fit, y/(x/px)=px*y/x
        sx=rows/ceil(px*rows/cols);
else
        sx= cols/px;
end
py=ceil(sqrt(k*rows/cols));
if(floor(py*cols/rows)*py< k) %does not fit
        sy=cols/ceil(cols*py/rows);
else
        sy=rows/py;
end

C = zeros(chan + 2 + 1, k);
l = -ones(rows, cols);   % Pixel labels.
d = inf(rows, cols);     % Pixel distances from cluster centres.

miter = 1;
for ci = 1:sx:cols
    for ri = 1:sy:rows
        rr = round(ri);
        cc = round(ci);
        C(1:chan, miter) = squeeze(im(rr,cc,:));
        C(chan+1:end-1, miter) =  [cc; rr];
        miter = miter+1;
    end
end
k = size(C, 2);
for n = 1:nItr
   for kk = 1:k  % for each cluster

       % Get subimage around cluster
       rmin = max(C(end - 1,kk)-sy, 1);
       rmax = min(C(end - 1,kk)+sy, rows); 
       cmin = max(C(end - 2,kk)-sx, 1);
       cmax = min(C(end - 2,kk)+sx, cols); 
       subim = im(rmin:rmax, cmin:cmax, :);  
       
       assert(numel(subim) > 0)
       
       for ll = 1:chan
            subim(:,:,ll) = (subim(:,:,ll)-C(ll, kk)).^2;
       end
       D = sum(subim, 3);
       [MX, MY] = meshgrid(cmin:cmax, rmin:rmax);
       
        MX = MX-C(end - 2, kk);
        MY = MY-C(end - 1, kk);
        D = D + (sig/sx) .* (MX.^2 + MY.^2);

       % If any pixel distance from the cluster centre is less than its
       % previous value update its distance and label
       subd =  d(rmin:rmax, cmin:cmax);
       subl =  l(rmin:rmax, cmin:cmax);
       updateMask = D < subd;
       subd(updateMask) = D(updateMask);
       subl(updateMask) = kk;

       d(rmin:rmax, cmin:cmax) = subd;
       l(rmin:rmax, cmin:cmax) = subl;           
   end

   % Update cluster centres with mean values
   C(:) = 0;
   tic;
   for kk = 1:k
    dis = l == kk;
    
    for dim = 1:6
        imd = im(:, :, dim);
        imd = imd(dis);
        C(dim, kk) = sum(sum(imd));
    end
    [rr, cc] = ind2sub([rows, cols], find(dis));
    C(7, kk) = sum(cc);
    C(8, kk) = sum(rr);
    C(9, kk) = length(cc);
   end
   time1 = toc;
   %C2 = C;
   %C2(:) = 0;
   %tic;
   %for r = 1:rows
   %    for c = 1:cols
   %       tmp = double([im(r,c,1); im(r,c,2); im(r,c,3); im(r,c,4);im(r,c,5);im(r,c,6);c; r; 1]);
   %       C2(:, l(r,c)) = C2(:, l(r,c)) + tmp;
   %    end
   %end
   %time2 = toc;

   % Divide by number of pixels in each superpixel to get mean values
   for kk = 1:k 
       C(1:end-1,kk) = round(C(1:end-1,kk)/C(end,kk)); 
   end
end

end

