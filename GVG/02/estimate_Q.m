function [Q, points_sel, err_max, err_points, Q_all] = estimate_Q( u, x, ix )

combs = nchoosek(ix, 6);
Q_all = cell(size(combs, 1) * 12, 1);
err_max = zeros(size(combs, 1) * 12, 1);

for i = 1:size(combs, 1)
    work_u = u(:, combs(i, :));
    work_u = work_u(:);
    work_x = x(:, combs(i, :));
    
    Qprep = zeros(12,12);
    for k = 1:size(work_x, 2)
       prep = [work_x(:,k)', 1];
       row = [prep, zeros(1, 4), -work_u(2*k - 1)*prep];
       Qprep(2*k - 1, :) = row;
       
       row = [zeros(1, 4), prep, -work_u(2*k)*prep];
       Qprep(2*k, :) = row;
    end
    for j = 1:size(work_u,1)
        nQ = Qprep;
        nQ(j, :) = [];
        q = null(nQ);
        Q = reshape(q, 4, 3)';
        proj_x = Q*[x;ones(1, size(x, 2))];
        proj_x = bsxfun(@rdivide, proj_x, proj_x(3,:));
        d2 = sqrt(sum((u-proj_x(1:2,:)).^2)); % for matrices with points stored in columns
        err_max((i-1)*12+j) = max(d2);
        Q_all{(i-1)*12+j} = Q;
    end
end
[~, ind] = min(err_max);
Q = Q_all{ind};
proj_x = Q*[x;ones(1, size(x, 2))];
proj_x = bsxfun(@rdivide, proj_x, proj_x(3,:));
err_points = proj_x(1:2, :) - u;
points_sel = combs(floor((ind-1) / 12) + 1, :);
end