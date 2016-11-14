function [s , distance] = kohw(A)
%addpath(path,'C:\Program Files (x86)\MATLAB\R2014b\toolbox\TORSCHE-master\scheduling')
% A  =  [ 1   2   3   4   5   6   7   8   9   3   6   5   3   4   2     7     4 ;
%             2   3   4   5   6   4   7   8   9   3   5   2   6   7   8     4     5 ;
%             4   5   7   8   9   3   6   4   6   8   4   5   2   7   4     5     4 ;
%             3   3   3   8   9   3   6   4   6   8   4   5   2   7   7     4    -1;
%             6   4   4   5   6   3   7   5   7   8   9   3   5   3   7    -1     0;
%             6   4   4   5   6   3   7   8   6   9   3   6   5   3   4     -1    4;
%             1   2   3   4   6   4   4   5   6   6   9   3   6   5   3     -1    0;
%             1   2   3   4   6   0   0   5   4   4   5   6   6   9   3     -1    0];


M = zeros(size(A, 1), size(A, 1));
M = diag(diag(M)*Inf);
for i = 1:size(A, 1)
    for j =i+1:size(A,1)
        M(i,j) = levensteihn(A(i,:), A(j,:));
    end
end
M = M+M';
g = graph(M);
s = spanningtree(g);
graphedit(s);
%%
edges = cell2mat(s.edl);
w = edges(:, 3);
w = w(~isnan(w));
distance = sum(w);
end

function [ distance] = levensteihn( a, b )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
ai = find(a == -1);
bi = find(b == -1);
if ai ~= 0
    A=a(1:ai-1);
else
    A = a;
end
if bi ~= 0
    B=b(1:bi-1);
else
    B = b;
end

DistM = zeros(length(A) + 1, length(B) + 1);
DistM(:, 1) = 0:length(A);
DistM(1, :) = 0:length(B);

[H, W] = size(DistM);

for i = 2:H
    for j=2:W
        if A(i-1) == B(j-1)
            insert = 0;
        else
            insert = 1;
        end
        DistM(i, j) = min(min(DistM(i-1, j) + 1, ...
                                     DistM(i, j-1) + 1) ...
                                     ,DistM(i-1, j-1) + insert); 
    end
end
distance = DistM(end, end);

end

