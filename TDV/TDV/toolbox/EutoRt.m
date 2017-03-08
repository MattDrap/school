function [R, t] = EutoRt( E, u1, u2 )
%EutoRT Ressecting Essential matrix to Rotation and translation
%Detailed explanation goes here
R = [];
t = [];
Gn = E/sqrt(trace(E'*E)/2);
[U,~,V] = svd(Gn);
v_t = U(:, 3);
v = V(:, 3);
if isempty(v)
    return;
end

vx = sqc(v);
g1 = Gn(:, 1); g2 = Gn(:, 2); g3 = Gn(:, 3);
v1 = vx(:, 1); v2 = vx(:, 2); v3 = vx(:, 3);
g12 = cross(g1, g2); g23 = cross(g2, g3); g13 = cross(g1, g3);
v12 = cross(v1, v2); v23 = cross(v2, v3); v13 = cross(v1, v3);

nG1 = [g1, g2, g3, g12, g23, g13];
nG2 = [-g1, -g2, -g3, g12, g23, g13];
nV = [v1, v2, v3, v12, v23 v13];

Rp = nG1*pinv(nV);
Rm = nG2*pinv(nV);
tp = v_t;
tm = -v_t;

R_all = {Rp, Rp, Rm, Rm};
t_all = {tp, tm, tp, tm};

P1 = [eye(3,3), zeros(3, 1)];
for j = 1:4
    P2 = [R_all{j} R_all{j}*t_all{j}];
    X = Pu2X(P1, P2, u1, u2);
    %dd = P2*X;
    %in_front = sum(dd(3, :) > 0);
    z = getDepth(P1, X);
    in_front = sum(z > 0);
    
    %dd1 = P1*X;
    z = getDepth(P2, X);
    %in_front = in_front + sum(dd1(3, :) > 0);
    in_front = in_front + sum(z > 0);
    if in_front  == 10
        R = R_all{j};
        t = t_all{j};
        break;
    end
end
end

