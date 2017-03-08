function X = Pu2X2( P1, P2, u1, u2 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
X = zeros(4, size(u1, 2));
for i = 1:size(u1, 2)
    D = [ u1(1, i) * P1(3, :) - P1(1, :);
          u1(2, i) * P1(3, :) - P1(2, :);
          u2(1, i) * P2(3, :) - P2(1, :);
          u2(2, i) * P2(3, :) - P2(2, :)];
    S = diag(1./max(abs(D),[], 1));
    [~, ~, V] = svd(D * S);
    X(:, i) = S * V(:, end);
end
end

