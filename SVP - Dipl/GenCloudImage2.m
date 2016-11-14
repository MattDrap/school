function [ nimg, cloud_mask ] = GenCloudImage2( img, metaballs, par )
    [H, W, C] = size(img);
    
    num_of_metaballs = size(metaballs, 1);
    
    nimg = img;
    
    white = ones(C, 1);
    if isa(img, 'uint8')
        %white = uint8(white .* 255);
    end
    cloud_mask = zeros(H,W);
    
    k2 = par.k2;
    angle0 = 90 - par.sun_elevation;
    angle0 = angle0 * pi / 180;
    
    m = repmat(metaballs(:, 1:2)', 1, 1, W);
    metaballsRs = repmat(metaballs(:, 3), 1, W);
    densities = repmat(metaballs(:, 4), 1, W);
    WWhite = repmat(white, 1, W);
    
    for i = 1:H
        coord = permute( repmat([1:W; repmat(i, 1, W)], [1, 1, num_of_metaballs] ), [1, 3, 2] );
    
        Wdists = squeeze(sqrt(sum( (coord - m) .^2)));

       % F = compute_f(Wdists, metaballs, W);

        lookup = Wdists <= metaballsRs;

        F = -4/9.*(Wdists./ metaballsRs).^6 + 17/9*(Wdists ./ metaballsRs).^4 ...
            - 22/9*(Wdists ./ metaballsRs).^2 + 1;
        F(~lookup) = 0;
        F = F .* densities;
        F = sum(F);
        cloud_mask(i ,:) = k2 .* angle0 .* F;

        C = repmat(cloud_mask(i, :), 3, 1) .* WWhite + squeeze(img(i, 1:W, :))';
        nimg(i, 1:W, :) = C';

        if mod(i, 100) == 0
            sprintf('%d / %d', i, H)
        end
    end

end

