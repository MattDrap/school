clear all;

im1 = uint8(imread('pokemon_03.jpg'));
im2 = uint8(imread('pokemon_29.jpg'));
ims = {im1, im2};
clear im1;
clear im2;

u1 = [];
u2 = [];
if ~exist('07_data.mat')
    mu = edit_points( ims, [], []);
    u1 = mu{1};
    u2 = mu{2};
    save('07_data.mat','u1', 'u2');
else
    load('07_data.mat');
end

vp1 = [];
p1 = zeros(3, 8);
for i = 1:3
    p1(:, i) = cross([u1(:, i); 1], [u1(:, i+1); 1]);
end
p1(:, 4) = cross([u1(:, 4); 1], [u1(:, 1); 1]);
for i=5:7
    p1(:, i) = cross([u1(:, i); 1], [u1(:, i+1); 1]);
end
p1(:, 8) = cross([u1(:, 8); 1], [u1(:, 5); 1]);

ind = [1,2,5,6];
for i = 1:4
    temp = cross(p1(:, ind(i)), p1(:, ind(i)+2));
    vp1 = [vp1, temp];
end

vp2 = [];
p2 = zeros(3, 8);
for i = 1:3
    p2(:, i) = cross([u2(:, i); 1], [u2(:, i+1); 1]);
end
p2(:, 4) = cross([u2(:, 4); 1], [u2(:, 1); 1]);
for i=5:7
    p2(:, i) = cross([u2(:, i); 1], [u2(:, i+1); 1]);
end
p2(:, 8) = cross([u2(:, 8); 1], [u2(:, 5); 1]);

for i = 1:4
    temp = cross(p2(:, ind(i)), p2(:, ind(i)+2));
    vp2 = [vp2, temp];
end

vp1 = bsxfun(@rdivide, vp1, vp1(3, :));
vp2 = bsxfun(@rdivide, vp2, vp2(3, :));

vp = {vp1, vp2};
u = {u1, u2};

% for k = 1:2
%     mu = u{k};
%     mvp = vp{k};
%     im = ims{k};
%     
%     f = figure;
%     hold on;
%     set(gca,'Ydir','reverse');
%     image(im);
%     axis tight equal;
%     
%     for i = 1:2
%         plot(mvp(1, i), mvp(2, i), 'rx');
%         for j = 1:4
%             plot([mvp(1, i) mu(1, j)], [mvp(2, i) mu(2, j)], 'r');
%         end
%     end
%     for i = 3:4
%         plot(mvp(1, i), mvp(2, i), 'bx');
%         for j = 5:8
%             plot([mvp(1, i) mu(1, j)], [mvp(2, i) mu(2, j)], 'b');
%         end
%     end
%     plot([mvp(1,1) mvp(1,4)], [mvp(2,1) mvp(2,4)], 'g');
%     fig2pdf(f, sprintf('07_vp%d.pdf', k));
% end
% clear im;
%%

v = [vp1(:, 1), vp1(:, 3), vp2(:, 3)];
v_ = [vp1(:, 2), vp1(:, 4), vp2(:, 4)];

A = [(v_(3, 1) * v(1, 1)+ v_(1, 1) * v(3, 1)), (v_(3, 1) * v(2, 1)+v_(2, 1) * v(3, 1)), (v_(3, 1) * v(3, 1));
     (v_(3, 2) * v(1, 2)+ v_(1, 2) * v(3, 2)), (v_(3, 2) * v(2, 2)+v_(2, 2) * v(3, 2)), (v_(3, 2) * v(3, 2));
     (v_(3, 3) * v(1, 3)+ v_(1, 3) * v(3, 3)), (v_(3, 3) * v(2, 3)+v_(2, 3) * v(3, 3)), (v_(3, 3) * v(3, 3))];
b = [-(v_(1, 1) * v(1, 1) + v_(2, 1) * v(2, 1));
    -(v_(1, 2) * v(1, 2) + v_(2, 2) * v(2, 2));
    -(v_(1, 3) * v(1, 3) + v_(2, 3) * v(2, 3))];
	
o = A\b;
k13 = -o(1);
k23 = -o(2);
k11 = sqrt(o(3) - k13^2 - k23^2);

K = [k11, 0, k13;
     0, k11, k23;
     0,0,1]
 %%
 iK = inv(K);
 Kmt = iK' * iK;
 
 angles = zeros(4, 1);
 angles(1) = (vp1(:, 2)' * Kmt * vp1(:, 3)) / (norm(iK*vp1(:, 2)) * norm(iK*vp1(:, 3)));
 angles(2) = (vp2(:, 2)' * Kmt * vp2(:, 3)) / (norm(iK*vp2(:, 2)) * norm(iK*vp2(:, 3)));
 angles(3) = (vp1(:, 1)' * Kmt * vp1(:, 4)) / (norm(iK*vp1(:, 1)) * norm(iK*vp1(:, 4)));
 angles(4) = (vp2(:, 1)' * Kmt * vp2(:, 4)) / (norm(iK*vp2(:, 1)) * norm(iK*vp2(:, 4)));
 
 angle = mean(angles([1,4]));

 %%
X = [0, 1, 0;
     0, 0, 1;
     0, 0, 0];
corner_pick = [8,7,5,8];
x_pick = [1,2,3,1];
c = zeros(3, 1);
d = zeros(3, 1);
for i = 1:3
    c(i) = ([u1(:,corner_pick(i)); 1]' * Kmt * [u1(:, corner_pick(i + 1)); 1] ) / ...
        (norm(iK * [u1(:, corner_pick(i)); 1]) * norm(iK * [u1(:, corner_pick(i + 1)); 1])); 
    d(i) = sqrt(sum((X(:, x_pick(i)) - X(:, x_pick(i+1))).^2));
end

[N1, N2, N3] = p3p_distances( d(1), d(2), d(3), c(1), c(2), c(3));
N = [N1(2), N2(2), N3(2)];
[R1, C1] = p3p_RC( N, u1(:, corner_pick(1:3)), X, K );
 %%
c = zeros(3, 1);
d = zeros(3, 1);
for i = 1:3
    c(i) = ([u2(:,corner_pick(i)); 1]' * Kmt * [u2(:, corner_pick(i + 1)); 1] ) / ...
        (norm(iK * [u2(:, corner_pick(i)); 1]) * norm(iK * [u2(:, corner_pick(i + 1)); 1])); 
    d(i) = sqrt(sum((X(:, x_pick(i)) - X(:, x_pick(i+1))).^2));
end

 [N1, N2, N3] = p3p_distances( d(1), d(2), d(3), c(1), c(2), c(3));
 N = [N1(1), N2(1), N3(1)];
 [R2, C2] = p3p_RC( N, u2(:, corner_pick(1:3)), X, K );
 
 %%
cube = [1 0 0 1 1 0 0 1;
        0 0 1 1 0 0 1 1;
        0 0 0 0 1 1 1 1];
 P1=[K*R1 -K*R1*C1];
 cubeProj = P1 * [cube; ones(1, size(cube, 2))];
 cubeProj = bsxfun(@rdivide, cubeProj, cubeProj(3, :));
 f = figure;
 hold on;
 set(gca,'Ydir','reverse');
 image(ims{1});
 drawCube(cubeProj);
 hold off;
 
 %fig2pdf(f, '07_box_wire1.pdf');
 P2=[K*R2 -K*R2*C2];
 cubeProj = P2 * [cube; ones(1, size(cube, 2))];
 cubeProj = bsxfun(@rdivide, cubeProj, cubeProj(3, :));
 f = figure;
 hold on;
  set(gca,'Ydir','reverse');
 image(ims{2});
 drawCube(cubeProj);
 hold off;
 %fig2pdf(f, '07_box_wire2.pdf');
 %%
 writerObj = VideoWriter('07_seq_wire.avi');
 writerObj.FrameRate = 1;
 open(writerObj);
 iters = 19;
 imref = ims{1};
 [Height, Width, Color] = size(imref);
 for i = 0:iters
    lambda = i/iters;
    C = (1-lambda)*C1 + lambda*C2;
    R = real( (R2*R1')^lambda * R1 );
    P = [K*R -K*R*C];
    H1 = P1(:, [1,2,4]);
    H2 = P(:, [1,2,4]);
    H = H1 * inv(H2);
    
    im = uint8(zeros(Height, Width, 3));
    for k = 1:Height
        for l = 1:Width
            proj = H*[l;k;1];
            proj(1) = proj(1)/proj(3);
            proj(2) = proj(2)/proj(3);
            proj = round(proj);
            if proj(2) < 1 || proj(2) > Height
                continue;
            end
            if proj(1) < 1 || proj(1) > Width
                continue;
            end
            im(k, l, :) = imref(proj(2), proj(1), :);
        end
    end
    f = figure;
    imshow(im);
    hold on;
    axis off;
    axis image;
    set(gca,'Ydir','reverse');
    set(gca,'Xdir','reverse');
    cubeProj = P * [cube; ones(1, size(cube, 2))];
    cubeProj = bsxfun(@rdivide, cubeProj, cubeProj(3, :));
    %cb = H * cubeProj;
    %cb = bsxfun(@rdivide, cb, cb(3, :));
    drawCube(cubeProj);
    fig = getframe(f);
    
    if i == 10
        fig2pdf(f, '07_box_wire3.pdf');
    end
    
    close(f);
    writeVideo(writerObj, fig);
 end
 close(writerObj);
 %%
 vp1 = vp1(1:2, :);
 vp2 = vp2(1:2, :);
save('07_data.mat','u1', 'u2', 'vp1', 'vp2', 'K', 'angle', 'C1', 'C2', 'R1', 'R2');
