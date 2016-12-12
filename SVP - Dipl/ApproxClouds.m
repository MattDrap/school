function [ metaClouds, metaErrs, I, lowClouds ] = ApproxClouds( GT, GT_mask, CloudImage, CloudImage_mask, par)

%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

[H, W, C] = size(GT);
mGT = GT;
mCloudImage = CloudImage;
str = strel('disk', 15);
Ref_mask = imerode(CloudImage_mask, str); %Eroded reference mask
mGT(repmat(CloudImage_mask, [1,1,C]) > 2) = 0;
mCloudImage(repmat(GT_mask, [1,1,C]) > 2) = 0;

probIm = mCloudImage;
probIm(repmat(Ref_mask, [1,1,C]) ~= 2) = 0;

max_metaClouds = par.max_metaClouds;

I = mGT;
Isun = 255;
IsunVec = 255 * ones(1,C);
angle0 = ((90 - par.sun_elevation) * pi )/ 180;

metaClouds = [];
metaErrs = [];
num_meta = 1;
while num_meta <= max_metaClouds
    
    probGT = I;
    probGT(repmat(CloudImage_mask, [1,1, C]) ~= 2) = 0;
    
    diffs = max(probIm - probGT, [], 3);
    
    metaErrs(num_meta) = max(diffs(:));%sum( (I(:) - mCloudImage(:)).^2 ) ...
                        %/ (H * W * C);
    if metaErrs(num_meta) < 6
        break;
    end
    
    [val, ind] = max(diffs(:));
    
    [row, col] = ind2sub([H, W], ind);
    
    center = [row, col];
    
    initDensity = double(probIm(row, col, :)) -  par.k1 .* double(mGT(row, col, :) );
    initDensity = reshape(initDensity, [1, C]) ./ (IsunVec * angle0 * par.k2 );
    
    if mod(num_meta, par.threshold) == 0
        fprintf('Init radius is now: %f\n', max(floor(par.init_radius - par.subb), 5));
        par.threshold = par.threshold*2;
        par.init_radius = max(floor(par.init_radius - par.subb), 5);
    end
    
    [maxradius, density] = MinimizeMetaball(probGT, probIm, center, initDensity, par);

     if sum(density ~= 0) == 0
         probIm(row, col, :) = mGT(row, col, :);
         'Zero density or radius'
         continue;
     end
    
    ymin = floor(row - maxradius);
    xmin = floor(col - maxradius);
    
    maxdiameter = 2 * maxradius;
    
    [subGT, new_center] = CropSat(I, center, maxradius);
    metaClouds(num_meta, :) = [col, row, maxradius, density'];
    %GrayGT = GenCloudImage(GrayGT, metaClouds);
    [CImage, cloud_mask] = GenCloudImage(subGT, double( [ new_center, metaClouds(end, 3:end) ]), par );
    xvec = xmin:xmin+ceil(maxdiameter);
    yvec = ymin:ymin+ceil(maxdiameter);
    
    clipX = xvec > size(I, 2) | xvec < 1;
    clipY = yvec > size(I, 1) | yvec < 1;
    xvec(clipX) = [];
    yvec(clipY) = [];
    
    I(yvec, xvec, :) = CImage(~clipY, ~clipX, :);
    cloud_white = uint8( cloud_mask(~clipY, ~clipX, :) .* Isun );
    probIm(yvec, xvec, :) = probIm(yvec, xvec, :) - cloud_white;
    probIm(row, col, :) = mGT(row, col, :);
    fprintf('Metaball %d/%d, Error %f \n', num_meta, max_metaClouds, metaErrs(num_meta));
    num_meta = num_meta + 1;
end

%low Clouds - approximated with bitmap
probGT = I;
probGT(CloudImage_mask ~= 2) = 0;

lowClouds = probIm - probGT;

end

