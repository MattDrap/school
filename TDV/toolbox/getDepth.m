function [ z ] = getDepth( P, X )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 Q = P(:,1:3);
 q = P(3,:)*X;
 detQ = det(Q);
 z = sign(detQ).*q./X(4,:)/norm(Q(3,:));
end

