function H=u2h(u)
%UNTITLED8 Summary of this function goes here
%   u = 6x4
%   [ x2, x2, x3, x4 ]
%   [ y2, y2, y3, y4 ]
%   [ 1, 1, 1, 1, 1]
%   [ x2' ...
%
u_1p = e2p(u(1:2, :));
u_2p = e2p(u(3:4, :));

u = [u_1p; u_2p];

T1 = normu(u(1:3, :));
T2 = normu(u(4:6, :));

u1 = T1 * u(1:3, :);
u2 = T2 * u(4:6, :);


X = u1;
x_ = u2(1, :);
y_ = u2(2, :);
    C = [ -X(:, 1)', 0,  0,  0,  x_(1) * X(:, 1)';
          0,  0,  0, -X(:, 1)',  y_(1) * X(:, 1)';
          -X(:, 2)', 0,  0,  0,  x_(2) *X(:, 2)';
          0,  0,  0, -X(:, 2)',  y_(2) * X(:, 2)';
          -X(:, 3)', 0,  0,  0,  x_(3) * X(:, 3)';
          0,  0,  0, -X(:, 3)',  y_(3) * X(:, 3)';
          -X(:, 4)', 0,  0,  0,  x_(4) * X(:, 4)';
          0,  0,  0, -X(:, 4)',  y_(4) * X(:, 4)'];
h = null(C);
%[~, ~, U] = svd(C);
if numel(h) ~= 9
    H = [];
    return;
end
H = reshape(h, 3, 3);
H = inv(T2) * H' * T1;

end

function T = normu(u)
%       -- Code found in attached pdf --
%       T = NORMU(u) finds normalization matrix T so that
%       mean(T*u)=0 and mean(||T*u||)=sqrt(2).
%       (see Hartley: In Defence of 8-point Algorithm, ICCV‘95)
%       Parameters:
%         u ... Size (2,N) or (3,N). Points to normalize.
%         T ... Size (3,3). Normalization matrix.
    m = mean(u(1:2,:),2); %find mean
    u = u(1:2,:) - m*ones(1,size(u,2)); %shift so means is zero
    distu = sqrt(sum(u.*u)); %distances/variances
    r = mean(distu)/sqrt(2); %shift so mean is sqrt(2)
    T  = diag([1/r 1/r 1]); %make matrix
    T(1:2,3) = -m/r;
end

