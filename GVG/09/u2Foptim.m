function [ bestF, bestE, err ] = u2Foptim( au1, au2, point_sel, K )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

err = Inf;
u1 = au1(:, point_sel);
u2 = au2(:, point_sel);
au1h = [au1; ones(1, size(au1, 2))];
au2h = [au2; ones(1, size(au2, 2))];

iK = inv(K);

pick = 1:size(u1, 2);
nk = nchoosek(pick, 8);
for i = 1:size(nk, 1)
    [F, G] = u2FG(u1(:, nk(i, :)), u2(:, nk(i, :)));
    
    Ex = K' * F * K;
    [U, D, V] = svd( Ex ); 
    D(2,2) = D(1,1);
    Ex = U * D * V';
    Fx = iK' * Ex * iK;
    
    l2 = Fx * au1h;
    l1 = Fx' * au2h;
    
    for j = 1:size(au1h, 2)
        dist1(j) = abs(l1(:, j)'*au1h(:, j))/(sqrt(l1(1,j).^2 + l1(2, j).^2));
        dist2(j) = abs(l2(:, j)'*au2h(:, j))/(sqrt(l2(1,j).^2 + l2(2,j).^2));
    end
    error = max(dist1 + dist2);
    if error < err
        err = error;
        bestF = Fx;
        bestE = Ex;
    end
end
end