function [ z ] = getDepth( P, X )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if size(X, 1) == 3
    X = e2p(X);
end
 Q = P(:,1:3);
 q = P(3,:)*X;
 detQ = det(Q);
 z = sign(detQ).*q./X(4,:)/norm(Q(3,:));
end

