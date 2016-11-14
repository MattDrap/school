function [ A ] = estimate_A( u2, u )
%estimate_A Estimate affine transformation matrix from set of points
%   No detail
    n = size(u,2); % number of columns
    combs = nchoosek(1:n, 3 );
    comb_number = size(combs, 1);
    e = zeros(comb_number, 1);
    
    u2homo = [u2; ones(1,size(u,2))];
    As = cell(comb_number, 1);
    
    for i = 1:size(combs, 1)
        points = u2homo(:, combs(i, :));
        A = u(:, combs(1, :)) /points;
        
        nu2 = A*u2homo;
        d2 = sqrt(sum((u-nu2).^2)); % for matrices with points stored in columns
        e(i) = max(d2);
        As{i} = A;
    end
    
    [~, ind] = min(e);
    A = As{ind};
end

