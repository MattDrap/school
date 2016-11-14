function [F, G] = u2FG( u1, u2 )
%u2FG Fundamental matrix 8 point algorithm
%   Detailed explanation goes here

u1p = [u1; ones(1, size(u1, 2))];
u2p = [u2; ones(1, size(u2, 2))];

H1 = normu(u1);
H2 = normu(u2);

u1n = H1 * u1p;  % u1p are homogeneous
u2n = H2 * u2p;  % u2p are homogeneous

M = [];
for i = 1:size(u1n, 2)
    M(i, :) = [(u2n(1, i) .* u1n(:, i))', (u2n(2, i) .* u1n(:, i))', (u2n(3, i) .* u1n(:, i))'];
end

Gx = null(M);
Gn = reshape(Gx, 3, 3);
Gn = Gn';
[U,D,V] = svd(Gn);
D(end, end) = 0;
Fn = U*D*V';
G = H2' * Gn * H1;
F = H2' * Fn * H1;
end

function T = normu(u)
    minX = min(u(1, :));
    minY = min(u(2, :));
    maxX = max(u(1, :));
    maxY = max(u(2, :));
    lu = [[minX;minY], [minX;maxY], [maxX;minY], [maxX;maxY]];
    ru = [[-1;-1], [-1;1], [1;-1], [1;1]];
    T = u2H(lu, ru);
    T = T./T(3,3);
end