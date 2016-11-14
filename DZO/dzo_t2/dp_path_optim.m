function [path_cost, path_idx] = dp_path_optim(...
    vertex_cost, topleft_cost, top_cost, topright_cost)
% Dynamic programming optimization to find for each vertex of MxN graph the
% shortest vertical path starting in arbitrary first row vertex.
%
% Input:
%   vertex_cost [MxN (double)] vertex_cost(i,j) is cost of the vertex (i,j)
%   topleft_cost [MxN (double)] topleft_cost(i,j) is cost of the edge
%     from the vertex (i-1,j-1) to vertex (i,j)
%   top_cost [MxN (double)] top_cost(i,j) is cost of the edge
%     from the vertex (i-1,j) to vertex (i,j)
%   topright_cost [MxN (double)] topright_cost(i,j) is cost of the edge
%     from the vertex (i-1,j+1) to vertex (i,j)
%
% Output:
%   path_cost [MxN (double)] path_cost(i,j) is the total cost of the
%     shortest vertical path starting in arbitrary first row vertex (1,*)
%     and ending in the vertex (i,j)
%   path_idx [MxN (double)] path_idx(i,j) is the column index of vertex
%     preceding the vertex (i,j) on the shortest vertical path from
%     arbitrary first row vertex (1,*) to the vertex (i,j); path_idx(i,j)
%     for i > 1 is from {j-1,j,j+1}; path_idx(1,j) can be aribtrary
[h, w] = size(vertex_cost);
path_cost = zeros(h,w);
path_idx = zeros(h,w);

path_cost(1,:) = vertex_cost(1,:);
for i = 2:h
   m = [Inf, path_cost(i-1,1:w-1) + topleft_cost(i,2:w);
    path_cost(i-1,:) + top_cost(i,:);
    path_cost(i-1,2:w) + topright_cost(i,1:w-1), Inf];
    
    %first
    [firstmin,firstind] = min(m(2:3,1));
    path_cost(i,1) = vertex_cost(i,1) + firstmin;
    path_idx(i,1) = firstind;
    %between
    [minimals, indices] = min(m(:,2:end-1));
    indices = indices - 2;
    path_cost(i,2:end-1) = minimals + vertex_cost(i,2:end-1);
    shifting = 2:w-1;
    path_idx(i,2:end-1) = indices + shifting;
    %last
    [lastmin,lastind] = min(m(1:2,end));
    path_cost(i,end) = vertex_cost(i,end) + lastmin;
    path_idx(i,end) = w + lastind - 2;
end

end
