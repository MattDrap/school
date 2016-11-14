function [Hbest, point_sel, max_error ]= u2h_optim(u, u0)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
N = size(u,2);
uh = [u; ones(1,size(u, 2))];

combs = nchoosek(1:N, 4);
lowest = Inf;

for i=1:size(combs, 1)
    H = u2H(u(:, combs(i, :)), u0(:, combs(i, :)));
    if isempty(H)
        continue;
    end
    proj = H*uh;
    proj(1, :) = proj(1, :)./proj(3, :);
    proj(2, :) = proj(2, :)./proj(3, :);
    
    
    dists = sqrt(sum((u0-proj(1:2, :)).^2));
    dist = max(dists);
    
    if dist < lowest
        Hbest = H;
        lowest = dist;
        point_sel = combs(i, :);
        max_error = dist;
    end
end
end

