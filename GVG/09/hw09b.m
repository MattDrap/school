
close all;
load('09a_data.mat')
load('K.mat');
load('edges.mat')
G = E;

Gn = (sqrt(2)*G)/norm(G, 'fro');
v = null(Gn);
vx = cross(repmat(v,1,3),eye(3,3)) ;

g1 = Gn(:, 1);
g2 = Gn(:, 2);
g3 = Gn(:, 3);

v1 = vx(:, 1);
v2 = vx(:, 2);
v3 = vx(:, 3);

g12 = cross(g1, g2);
g23 = cross(g2, g3);
g13 = cross(g1, g3);

v12 = cross(v1, v2);
v23 = cross(v2, v3);
v13 = cross(v1, v3);

nG1 = [g1, g2, g3, g12, g23, g13];
nG2 = [-g1, -g2, -g3, g12, g23, g13];
nV = [v1, v2, v3, v12, v23 v13];


Rp = nG1*pinv(nV);
Rm = nG2*pinv(nV);
tp = v;
tm = -v;

P2pp = Rp*[eye(3,3), -tp];
P2pm = Rp*[eye(3,3), -tm];
P2mp = Rm*[eye(3,3), -tp];
P2mm = Rm*[eye(3,3), -tm];

u1h = [u1; ones(1, size(u1, 2))];
u2h = [u2; ones(1, size(u2, 2))];
P1 = [eye(3,3), zeros(3, 1)];
P1 = K*P1;

P2 = {P2pp, P2pm, P2mp, P2mm};
P2 = cellfun(@(x) K*x, P2, 'UniformOutput' , false);

best_in_front = 0;
best_P2 = [];
for j = 1:4
    in_front = 0;
    for i = 1:size(u1h, 2)
        M = [[u1h(:, i); zeros(3, 1)], [zeros(3,1); u2h(:, i)], [-P1;-P2{j}]];
        [M1, M2, M3] = svd(M);
        M2(end, end) = 0;
        M = M1 * M2 * M3';
        ret = null(M);
        if(ret(end - 1) / ret(end) > 0)
            in_front = in_front + 1;
        end
        dd = P2{j}*ret(3:end);
        if(dd(3) > 0)
            in_front = in_front + 1;
        end
    end
    if in_front > best_in_front
        best_in_front = in_front;
        best_P2 = P2{j};
    end
end

P2 = P2{4};%best_P2;
R = Rm;
C = tm;
points = zeros(4, size(u1h, 2));
for i = 1:size(u1h, 2)
    M = [[u1h(:, i); zeros(3, 1)], [zeros(3,1); u2h(:, i)], [-P1;-P2]];
    [M1, M2, M3] = svd(M);
    M2(end, end) = 0;
    M = M1 * M2 * M3';
    ret = null(M);
    ret = bsxfun(@rdivide, ret, ret(6));
    points(:, i) = ret(3:6);
    %plot3(ret(3), ret(4), ret(5), 'xr', 'MarkerSize', 8); 
end
%%
f = figure;
hold on;
f1 = subplot(1, 2, 1);
imagesc(ims{1});
axis equal;
f2 = subplot(1, 2, 2);
imagesc(ims{2});
axis equal;

pp1 = P1 * [points(1:3, :); ones(1, size(points, 2))];
pp1 = bsxfun(@rdivide, pp1, pp1(3, :));
pp2 = P2 * [points(1:3, :); ones(1, size(points, 2))];
pp2 = bsxfun(@rdivide, pp2, pp2(3, :));

for i = 1:size(u1h, 2)
    set( f, 'currentaxes',  f1 );
    hold on;
    plot(u1(1, i), u1(2, i), 'b.', 'MarkerSize', 4);
    
    plot(pp1(1, i), pp1(2, i), 'ro');
   
    
    set( f, 'currentaxes',  f2 );
    hold on;
    plot(u2(1, i), u2(2, i), 'b.');
    
    plot(pp2(1, i), pp2(2, i), 'ro');
end
for i = 1:size(edges,2)
 set( f, 'currentaxes',  f1 );
 hold on;
 plot([pp1(1, edges(1, i)), pp1(1, edges(2, i))],...
        [pp1(2, edges(1, i)), pp1(2, edges(2, i))], 'y');
 set( f, 'currentaxes',  f2 );
 hold on;   
 plot([pp2(1, edges(1, i)), pp2(1, edges(2, i))],...
    [pp2(2, edges(1, i)), pp2(2, edges(2, i))], 'y');
end
fig2pdf(f, '09_reprojection.pdf')
%%
f = figure;
hold on;
d1 = sqrt(sum((u1-pp1(1:2, :)).^2));
d2 = sqrt(sum((u2-pp2(1:2, :)).^2));
plot(1:size(d1, 2), d1);
plot(1:size(d2, 2), d2);
ylabel('Error');
legend('u1 - P1*x', 'u2 - P2*x');
fig2pdf(f, '09_errorsr.pdf')
%%
f = figure;
hold on;

for i = 1:size(points, 2)
    plot3(points(1, i), points(2, i), points(3, i), 'xr', 'MarkerSize', 6);
end

for i = 1:size(edges, 2)
    plot3([points(1, edges(1, i)), points(1, edges(2, i))],...
        [points(2, edges(1, i)), points(2, edges(2, i))], ...
        [points(3, edges(1, i)), points(3, edges(2, i))])
end
X = points(1:3, :);
save('09b_data.mat', 'Fe', 'E', 'R', 'C', 'P1', 'P2', 'X', 'u1', 'u2', 'point_sel');