function err = err_F( F, u1, u2 )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    
    l2 = F * u1;
    l1 = F' * u2;
    
    for j = 1:size(u1, 2)
        dist1(j) = abs(l1(:, j)'*u1(:, j))/(sqrt(l1(1,j).^2 + l1(2, j).^2));
        dist2(j) = abs(l2(:, j)'*u2(:, j))/(sqrt(l2(1,j).^2 + l2(2,j).^2));
    end
    err = (dist1 + dist2).^2;

end
