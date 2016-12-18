function [ metaClouds, metaErrs, I, lowClouds ] = ApproxClouds( GT, GT_mask, CloudImage, CloudImage_mask, par)

%APPROXCLOUDS Approximate clouds from satellite images
%   Approximate clouds based on Ground Truth (GT) and Ground Truth mask
%   (GT_mask), and reference image that we want to get (CloudImage) and
%   it's CloudImage_mask with given parameters (par) -- set by Config

[H, W, C] = size(GT);
mGT = GT;
mCloudImage = CloudImage;

%Eroding, because we want to get rid of potentialy lonely pixels, that
%probably are not clouds and we dont want to instance cloud on edge of the
%cloud
str = strel('disk', 15);
Ref_mask = imerode(CloudImage_mask, str); %Eroded reference mask

%Cross erasing failures of images so GT would be in same bad situation as
%cloud image and removing non suposedly Cloud pixels
mGT(repmat(CloudImage_mask, [1,1,C]) > 2) = 0;
mCloudImage(repmat(GT_mask, [1,1,C]) > 2) = 0;

probIm = mCloudImage;
probIm(repmat(Ref_mask, [1,1,C]) ~= 2) = 0;

max_metaClouds = par.max_metaClouds;

I = mGT;
%Given sun elevation that is elevation from x plane but we need angle from
%y plane
Isun = 255;
IsunVec = 255 * ones(1,C);
angle0 = ((90 - par.sun_elevation) * pi )/ 180;

metaClouds = {};
metaErrs = [];
num_meta = 1;

%%
%Different strategy
possible_radius = par.min_radius:par.init_radius;
pdf = 1./possible_radius.^2;
pdf = pdf / sum(pdf);
denspdf = cumsum(pdf);
denspdf = [0, denspdf(1: end -1)];
%%
while num_meta <= max_metaClouds
    
    probGT = I;
    probGT(repmat(CloudImage_mask, [1,1, C]) ~= 2) = 0;
    
    %Metric of cloud problem
    diffs = max(probIm - probGT, [], 3);
    
    [val, ind] = max(diffs(:));
    metaErrs(num_meta) = val;%sum( (I(:) - mCloudImage(:)).^2 ) ...
                        %/ (H * W * C);
    %Stopping criterion based on given metric
    if metaErrs(num_meta) < 6
        break;
    end
    
    %Find possible center of a cloud
    [row, col] = ind2sub([H, W], ind);
    
    center = [row, col];
    
    %Initialize density based on approximated and estimated equation
    initDensity = double(probIm(row, col, :)) -  par.k1 .* double(mGT(row, col, :) );
    initDensity = reshape(initDensity, [1, C]) ./ (2 * IsunVec * angle0 * par.k2 );
    %OPTION? Mean all init?
    initDensity = repmat(mean(initDensity), 1, C);
    
    randnum = rand();
    par.init_radius = possible_radius(find(denspdf <= randnum, 1, 'last'));
    %
    %Decrease constantly initial radius and increase linearly number of
    %metaballs
%     if mod(num_meta, par.threshold) == 0
%         fprintf('Init radius is now: %f\n', max(floor(par.init_radius - par.subb), par.min_radius));
%         par.threshold = par.threshold*2;
%         par.init_radius = max(floor(par.init_radius - par.subb), par.min_radius);
%     end
    [maxradius, density] = MinimizeMetaball(probGT, probIm, center, initDensity, par);
    
    %Remove densities which are zeros
     if sum(density ~= 0) == 0
         probIm(row, col, :) = mGT(row, col, :);
         'Zero density or radius'
         continue;
     end
    %Get rectangle from radius
    ymin = floor(row - maxradius);
    xmin = floor(col - maxradius);
    
    maxdiameter = 2 * maxradius;
    
    [subGT, new_center] = CropSat(I, center, maxradius);
    
    [CImage, cloud_mask] = GenCloudImage(subGT, double( [ new_center, maxradius, density' ]), par );
    metaClouds(num_meta, :) = {col, row, maxradius, density', cloud_mask};
    
    %Remove pixels from images that are out of the border
    xvec = xmin:xmin+ceil(maxdiameter);
    yvec = ymin:ymin+ceil(maxdiameter);
    
    clipX = xvec > size(I, 2) | xvec < 1;
    clipY = yvec > size(I, 1) | yvec < 1;
    xvec(clipX) = [];
    yvec(clipY) = [];
    
    I(yvec, xvec, :) = CImage(~clipY, ~clipX, :);
    cloud_white = uint8( cloud_mask(~clipY, ~clipX, :) .* Isun );
    %Remove clouded addition from Reference Cloud Image
    probIm(yvec, xvec, :) = probIm(yvec, xvec, :) - cloud_white;
    %Stabilize solution by setting cloud center to value of ground truth
    probIm(row, col, :) = mGT(row, col, :);
    fprintf('Metaball %d/%d, Error %f \n', num_meta, max_metaClouds, metaErrs(num_meta));
    num_meta = num_meta + 1;
end

%low Clouds - approximated with bitmap
probGT = I;
probGT(CloudImage_mask ~= 2) = 0;

lowClouds = probIm - probGT;

end

