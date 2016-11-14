function [ f ] = compute_f( dists, metaballs, Width)
metaballsRs = repmat(metaballs(:, 3), 1, Width);
lookup = dists <= metaballsRs;

  f = -4/9.*(dists./ metaballsRs).^6 + 17/9*(dists ./ metaballsRs).^4 ...
        - 22/9*(dists ./ metaballsRs).^2 + 1;
 f(~lookup) = 0;
 densities = repmat(metaballs(:, 4), 1, Width);
 f = f .* densities;
 f = sum(f);
 

end