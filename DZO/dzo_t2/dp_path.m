function [path, path_cost, path_idx] = dp_path(...
    vertex_cost, topleft_cost, top_cost, topright_cost)
% Find the shortest vertical path (with respect to the specified vertex and
% edge cost matrices) in MxN graph going from arbitrary first row vertex to
% arbitrary last row vertex.
%
% Input:
%   vertex_cost [MxN (double)] vertex_cost(i,j) is cost of the vertex (i,j)
%   topleft_cost [MxN (double)] topleft_cost(i,j) is cost of the edge
%     from the vertex (i-1,j-1) to vertex (i,j); this parameter is optional
%     and if it is not defined then zero costs are used
%   top_cost [MxN (double)] top_cost(i,j) is cost of the edge
%     from the vertex (i-1,j) to vertex (i,j); this parameter is optional
%     and if it is not defined then zero costs are used
%   topright_cost [MxN (double)] topright_cost(i,j) is cost of the edge
%     from the vertex (i-1,j+1) to vertex (i,j); this parameter is optional
%     and if it is not defined then zero costs are used
%
% Output:
%   path [Mx1 (double)] path(i) = j if the shortest vertical path from
%     the first row to the last row goes through the vertex (i,j)
%   path_cost [MxN (double)] path_cost(i,j) is the total cost of the
%     shortest vertical path starting in arbitrary first row vertex (1,*)
%     and ending in the vertex (i,j)
%   path_idx [MxN (double)] path_idx(i,j) is the column index of vertex
%     preceding the vertex (i,j) on the shortest vertical path from
%     arbitrary first row vertex (1,*) to the vertex (i,j); path_idx(i,j)
%     for i > 1 is from {j-1,j,j+1}; path_idx(1,j) can be aribtrary

[h, w] = size(vertex_cost);

% deal with undefined edge costs
if ~exist('topleft_cost', 'var')
    topleft_cost = zeros(h, w);
end
if ~exist('top_cost', 'var')
	top_cost = zeros(h, w);
end
if ~exist('topright_cost', 'var')
	topright_cost = zeros(h, w);
end
[path_cost, path_idx] = dp_path_optim(vertex_cost, topleft_cost,...
    top_cost, topright_cost);
path = dp_path_trace(path_cost, path_idx);


