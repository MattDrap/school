function [ nimg, cloud_mask ] = GenCloudImage( img, metaballs, par )
    [H, W, C] = size(img);
    
    num_of_metaballs = size(metaballs, 1);
    
    nimg = img;
    
    white = ones(C, 1);
    if isa(img, 'uint8')
        white = uint8(white .* 255);
    end
    cloud_mask = zeros(H,W);
    
    k2 = par.k2;
    angle0 = 90 - par.sun_elevation;
    angle0 = angle0 * pi / 180;
    
    for i = 1:H
        for j=1:W
            dists = sqrt(sum((repmat([j, i], num_of_metaballs, 1) - [metaballs(:, 1:2)]).^2, 2));
            lookup = dists < metaballs(:, 3);
            ballsR = metaballs(:, 3);
            f = -4/9.*(dists ./ ballsR).^6 + 17/9*(dists ./ ballsR).^4 ...
               - 22/9*(dists ./ ballsR).^2 + 1;
           
            f(~lookup) = 0;
            cloud_mask(i,j) = k2 * angle0 * sum(metaballs(:, 4) .* f);
            
            %nimg(i, j, :) =  (cloud_mask(i, j) * white + (1 - cloud_mask(i, j)) * squeeze(img(i, j, :)));
            nimg(i, j, :) =  (cloud_mask(i, j) * white + squeeze(img(i, j, :)));
        end
        if mod(i, 100) == 0
            sprintf('%d / %d', i, H)
        end
    end
end