function [ metaClouds, metaErrs, I ] = ApproxClouds( GrayGT, GT_mask, CloudImage, CloudImage_mask, par)
GrayGT(CloudImage_mask > 2) = 0;
CloudImage(GT_mask > 2) = 0;

probIm = CloudImage;
probIm(CloudImage_mask ~= 2) = 0;


max_metaClouds = par.max_metaClouds;

I = GrayGT;
Isun = 255;
angle0 = ((90 - par.sun_elevation) * pi )/ 180;

metaClouds = [];
metaErrs = [];

for num_meta = 1:max_metaClouds
    
    probGT = I;
    probGT(CloudImage_mask ~= 2) = 0;
    
    metaErrs(num_meta) = sum( (I(:) - CloudImage(:)).^2 ) ...
                        / (size(I, 1) * size(I, 2));
    if metaErrs(num_meta) < 5
        break;
    end
    
    [val, ind] = max( probIm(:) );
    [mi, mj] = ind2sub(size(probIm), ind);
    
    center = [mi, mj];
    
    initDensity = ( double(probIm(mi, mj)) -  par.k1 * double(GrayGT(mi, mj) ) ) / (3 * Isun * angle0 * par.k2 );
    
    [maxradius, density] = MinimizeMetaball(probGT, probIm, center, initDensity , par);

    if density == 0
        num_meta = num_meta - 1;
        probIm(mi, mj) = 0;
        continue;
    end
    
    up_radius = maxradius + par.raise_crop;
    row1 = floor(mj - up_radius/2);
    col1 = floor(mi - up_radius/2);
    
    subGT = imcrop(I, [row1, col1, up_radius, up_radius]);
    metaClouds(num_meta, :) = [mj, mi, maxradius, density];
    %GrayGT = GenCloudImage(GrayGT, metaClouds);
    CImage = GenCloudImage(subGT, double( [ size(subGT, 2)/2, size(subGT, 1)/2, metaClouds(end, 3:4) ]), par );
    t1 = col1:col1+up_radius;
    t2 = row1:row1+up_radius;
    
    t1(t1 > size(I, 1)) = [];
    t2(t2 > size(I, 2)) = [];
    t1(t1 < 1) = [];
    t2(t2 < 1) = [];
    
    I(t1, t2) = CImage;
    probIm(t1, t2) = probIm(t1, t2) - CImage;
    fprintf('Metaball %d/%d \n', num_meta, max_metaClouds);
end
end