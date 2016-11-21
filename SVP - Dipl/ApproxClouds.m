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
num_meta = 1;
while num_meta <= max_metaClouds
    
    probGT = I;
    probGT(CloudImage_mask ~= 2) = 0;
    
    metaErrs(num_meta) = sum( (I(:) - CloudImage(:)).^2 ) ...
                        / (size(I, 1) * size(I, 2));
    if metaErrs(num_meta) < 6
        break;
    end
    
    [val, ind] = max( probIm(:) );
    [row, col] = ind2sub(size(probIm), ind);
    
    center = [row, col];
    
    initDensity = ( double(probIm(row, col)) -  par.k1 * double(GrayGT(row, col) ) ) / (Isun * angle0 * par.k2 );
    
    [maxradius, density] = MinimizeMetaball(probGT, probIm, center, initDensity , par);

    if density == 0
        probIm(row, col) = 0;
        'Zero density or radius'
        continue;
    end
    
    ymin = floor(row - maxradius);
    xmin = floor(col - maxradius);
    
    maxdiameter = 2 * maxradius;
    
    subGT = imcrop(I, [xmin, ymin, maxdiameter, maxdiameter]);
    metaClouds(num_meta, :) = [col, row, maxradius, density];
    %GrayGT = GenCloudImage(GrayGT, metaClouds);
    [CImage, cloud_mask] = GenCloudImage(subGT, double( [ size(subGT, 2)/2, size(subGT, 1)/2, metaClouds(end, 3:4) ]), par );
    xvec = xmin:xmin+ceil(maxdiameter);
    yvec = ymin:ymin+ceil(maxdiameter);
    
    xvec(xvec > size(I, 2)) = [];
    yvec(yvec > size(I, 1)) = [];
    xvec(xvec < 1) = [];
    yvec(yvec < 1) = [];
    
    I(yvec, xvec) = CImage;
    cloud_white = uint8( cloud_mask .* Isun );
    probIm(yvec, xvec) = probIm(yvec, xvec) - cloud_white;
    probIm(row, col) = 0;
    fprintf('Metaball %d/%d \n', num_meta, max_metaClouds);
    num_meta = num_meta + 1;
end
end