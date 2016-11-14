close all;
Dalib = load( 'daliborka_01-ux.mat' );
ix = load('IXPoints.txt');

C = [1;2;3];
f=1;
R = diag( [1 1 1] );
K = R;
X1 = [0 0 0]';
X2 = [1 0 0]';
X3 = [0 1 0]';

X = [X1, X2, X3];
X = [X; ones(1, 3)];

P = [K*R, -K*R*C];
X_star = P*X;

invK = inv(K);
KTK = invK'*invK;

Xtest = bsxfun(@rdivide, X_star, X_star(3,:));

c = zeros(3,1);
d = zeros(3,1);
for i = 1:3
    j = mod(i, 3) + 1;
    c(i) = ( Xtest(:,i)' * KTK * Xtest(:, j) ) / ...
        (norm(invK * Xtest(:, i)) * norm(invK * Xtest(:, j))); 
    d(i) = sqrt(sum((X(:, i) - X(:, j)).^2));
end

[N1, N2, N3] = p3p_distances(d(1), d(2), d(3), c(1), c(2), c(3));

%test
%N1 * Xtest(:, 1) / norm(Xtest(:, 1)) - C == X1
%N2 * Xtest(:, 2) / norm(Xtest(:, 2)) - C == X2
%N3 * Xtest(:, 3) / norm(Xtest(:, 3)) - C == X3

%%
X1 = [1 0 0]'; X2 = [0 2 0]'; X3 = [0 0 3]'; c12 = 0.9037378393; c23 = 0.8269612542; c31 = 0.9090648231;
X = [X1, X2, X3];
for i = 1:3
    j = mod(i, 3) + 1;    
    d(i) = sqrt(sum((X(:, i) - X(:, j)).^2));
end
[N1, N2, N3] = p3p_distances(d(1), d(2), d(3), c12, c23, c31);
%%
X1 = [1 0 0]'; X2 = [0 1 0]'; X3 = [0 0 2]'; c12 = 0.8333333333; c23 = 0.7385489458; c31 = 0.7385489458;
X = [X1, X2, X3];
for i = 1:3
    j = mod(i, 3) + 1;    
    d(i) = sqrt(sum((X(:, i) - X(:, j)).^2));
end
[N1, N2, N3] = p3p_distances(d(1), d(2), d(3), c12, c23, c31);
%%
X1 = [1 0 0]'; X2 = [0 2 0]'; X3 = [0 0 3]'; c12 = 0; c23 = 0; c31 = 0;
X = [X1, X2, X3];
for i = 1:3
    j = mod(i, 3) + 1;    
    d(i) = sqrt(sum((X(:, i) - X(:, j)).^2));
end
[N1, N2, N3] = p3p_distances(d(1), d(2), d(3), c12, c23, c31);
%%
load('K.mat');
points3d = Dalib.x(:, ix);
ind = nchoosek(1:size(points3d, 2), 3);

u = Dalib.u(:, ix);

invK = inv(K);
KTK = invK'*invK;
AllN1 = [];
AllN2 = [];
AllN3 = [];

for k = 1:size(ind, 1)
    mpoints = points3d(:, ind(k, :));
    c = zeros(3,1);
    d = zeros(3,1);
    mu = u(:, ind(k, :));
    mu = [mu; [1,1,1]];
    for i = 1:3
        j = mod(i, 3) + 1;
        c(i) = ( mu(:,i)' * KTK * mu(:, j) ) / ...
            (norm(invK * mu(:, i)) * norm(invK * mu(:, j))); 
        
        d(i) = sqrt(sum((mpoints(:, i) - mpoints(:, j)).^2));
    end

    [N1, N2, N3] = p3p_distances(d(1), d(2), d(3), c(1), c(2), c(3));
    
    AllN1 = [AllN1, N1];
    AllN2 = [AllN2, N2];
    AllN3 = [AllN3, N3];
end
fig1 = figure;
hold on;
plot(AllN1, 'r');
plot(AllN2, 'b');
plot(AllN3, 'g');
legend('\eta_1', '\eta_2', '\eta_3');
ylabel('distance [m]')
xlabel('trial');
hold off;
fig2pdf(fig1, '04_distances.pdf');

