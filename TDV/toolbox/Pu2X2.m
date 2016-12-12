function X = Pu2X( P1, P2, u1, u2 )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
X = zeros(4, size(u1, 2));
for i = 1:size(u1, 2)
    M = [[u1(:, i); zeros(3, 1)], [zeros(3,1); u2(:, i)], [-P1;-P2]];
    [M1, M2, M3] = svd(M);
    M2(end, end) = 0;
    M = M1 * M2 * M3';
    res = null(M);
    X(:, i) = res(3:end);
end

end

