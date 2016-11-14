function [ metaClouds, metaErrs, GrayGT ] = ApproxClouds2( GrayGT, GT_mask, CloudImage, CloudImage_mask, par)
GrayGT(CloudImage_mask > 2) = 0;
CloudImage(GT_mask > 2) = 0;

probIm = CloudImage;
probIm(CloudImage_mask ~= 2) = 0;

densityt = par.densityt;
radiust = par.radiust;
maxradius = par.maxradius;
max_metaClouds = par.max_metaClouds;

metaClouds = [];
metaErrs = [];

for num_meta = 1:max_metaClouds
    probGT = GrayGT;
    probGT(CloudImage_mask ~= 2) = 0;
    
    metaErrs(num_meta) = sum( (GrayGT(:) - CloudImage(:)).^2 ) ...
                        / (size(GrayGT, 1) * size(GrayGT, 2));
    if sum( (GrayGT(:) - CloudImage(:)).^2 ) ...
        / (size(GrayGT, 1) * size(GrayGT, 2)) < 5
        break;
    end
    
    [val, ind] = max( probIm(:) );
    [mi, mj] = ind2sub(size(probIm), ind);
    
    center = [mi, mj];

    row1 = floor(mj - maxradius/2);
    col1 = floor(mi - maxradius/2);

    MSErr = [];
    maxdensity = 1;
    density = maxdensity;
    
    subGT = imcrop(probGT, [row1, col1, maxradius, maxradius]);
    for i = radius:radiust:maxradius
        subprob = imcrop(probIm, [row1, col1, maxradius, maxradius]) ;
        CImage = GenCloudImage(subGT, double( [size(subprob, 2)/2, size(subprob, 1)/2, i, density] ));

        tempmask = CImage > 0;

        MSErr = [MSErr; ...
            sum( (subprob(tempmask) - CImage(tempmask)).^2 ) ...
            / (size(subprob, 1) * size(subprob, 2)) ];
        density = density - densityt;
        if abs(density) < 1e-8
            break;
        end
    end
    [vm, vi] = min(MSErr);
    metaClouds(num_meta, :) = [mj, mi, (vi - 1) * radiust + radius, maxdensity - (vi - 1) * densityt];
    %GrayGT = GenCloudImage(GrayGT, metaClouds);
    CImage = GenCloudImage(subGT, double( [ size(subprob, 2)/2, size(subprob, 1)/2, metaClouds(end, 3:4) ] ) );
    t1 = col1:col1+maxradius;
    t2 = row1:row1+maxradius;
    
    t1(t1 > size(GrayGT, 1)) = [];
    t2(t2 > size(GrayGT, 2)) = [];
    t1(t1 < 1) = [];
    t2(t2 < 1) = [];
    
    GrayGT(t1, t2) = CImage;
    probIm(t1, t2) = probIm(t1, t2) - CImage;
end
end

end

