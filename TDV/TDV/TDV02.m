clear all;
close all;
clc;
addpath('../Misc');

z = 4;
X1 = [-0.5  0.5 0.5 -0.5 -0.5 -0.3 -0.3 -0.2 -0.2  0  0.5;
      -0.5 -0.5 0.5  0.5 -0.5 -0.7 -0.9 -0.9 -0.8 -1 -0.5;
       z    z   z    z    z    z    z    z    z  z    z ];
X2 = X1;
X2(3,:) = X1(3,:)+0.5;

K = [ 1000    0 500;
         0 1000 500;
         0    0   1 ];
%%
%1.I
R =  eye(3,3);
C = [0; 0; 0];
P1 = K*R*[eye(3,3), -C];

%%
%1.II

R =  eye(3,3);
C = [0; -1; 0];
P2 = K*R*[eye(3,3), -C];
%%
%1.III
R =  eye(3,3);
C = [0; 0.5; 0];
P3 = K*R*[eye(3,3), -C];
%%
%1.IV
R =  [1, 0, 0;
      0, cos(0.5), -sin(0.5);
      0, sin(0.5), cos(0.5)];
C = [0; -3; 0.5];
P4 = K*R*[eye(3,3), -C];
%%
%1.V
rot = pi/2;
R =  [1, 0, 0;
      0, cos(rot), -sin(rot);
      0, sin(rot), cos(rot)];
C = [0; -5; 4.2];
P5 = K*R*[eye(3,3), -C];
%%
%1.VI
rot1 = -0.5;
R1 =  [cos(rot1), 0, sin(rot1);
      0, 1, 0;
      -sin(rot1), 0, cos(rot1)];
rot2 = 0.8;
R2 =  [1, 0, 0;
      0, cos(rot2), -sin(rot2);
      0, sin(rot2), cos(rot2)];
R = R2*R1;
C = [-1.5; -3; 1.5];
P6 = K*R*[eye(3,3), -C];
%%
P = {P1, P2, P3, P4, P5, P6};
for i = 1:size(P, 2)
    u1  = p2e(P{i}*e2p(X1));
    u2  = p2e(P{i}*e2p(X2));

    figure;
    hold on;
    title(sprintf('Camera %d', i));
    plot( u1(1,:), u1(2, :), 'r-', 'linewidth', 2 )
    plot( u2(1,:), u2(2, :), 'b-', 'linewidth', 2 )
    plot( [u1(1, :); u2(1, :)], [u1(2, :); u2(2, :)], 'k-', 'linewidth', 2 );
    set( gca, 'ydir', 'reverse' )
    axis equal
    hold off;
end