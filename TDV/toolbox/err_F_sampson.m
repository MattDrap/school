function err = err_F_sampson( F, u1, u2 )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    
    err = zeros(1, size(u1, 2));
    S = [1, 0, 0;
         0, 1, 0;
         0, 0, 0];
    for j = 1:size(u1, 2)
        e = (u2(:,j)' * F * u1(:,j)).^2;
        err(j) = e / (sum ( S * (F * u1(:, j)).^2 )  + sum ( S * (F' * u2(:, j)).^2 ) );
    end
end

