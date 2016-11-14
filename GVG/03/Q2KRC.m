function [ K, R, C ] = Q2KRC( Q )
%Q2KRC Summary of this function goes here
%   Detailed explanation goes here

M = Q(1:3, 1:3);
m = Q(1:3, 4);

SM = sign(det(M))*M;

m3_n = norm(SM(3, :));
k13 = SM(1,:)*SM(3,:)' / (m3_n ^ 2);
k23 = SM(2,:)*SM(3,:)' / (m3_n ^ 2);
prek22 = SM(2,:)*SM(2,:)' / (m3_n ^ 2);
k22 = sqrt( prek22 - (k23 ^ 2));
prek12 = SM(1,:)*SM(2,:)'  / (m3_n ^ 2); 
k12 = (prek12 - k13*k23) / k22;
prek11 = SM(1,:)*SM(1,:)' / (m3_n ^ 2);
k11 = sqrt(prek11 - (k12 ^ 2) - (k13 ^ 2));

K = [k11, k12, k13;
     0,   k22, k23;
     0,     0,   1];

R = inv(K)* (sign(det(M))/norm(M(3,:))) * M;

C = -inv(M) * m;
end

