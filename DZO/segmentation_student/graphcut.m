function lab = graphcut(cost_unary, pairs, cost_pair)
% Find optimum classification of pixels by finding minimum cut (maximum
% flow) in specifically constructed graph. Each pixel vertex is connected
% with foreground and background vertex. The edges are assigned certain
% unary costs q1(t) and q2(t). Moreover, each pair of neighboring pixels
% is connected by edge which is assigned certain pairwise cost r(t,s).
%
% Input:
%   cost_unary [2xN (double)] for each of N pixels cost_unary(1,i) is
%     the cost of the edge going from i-th pixel vertex to the vertex
%     representing class 1, cost_unary(2,i) is the cost of the edge from
%     i-th pixel to class 2
%   pairs [2xM (double)] M pairs of 1D indices of neighboring pixels; every
%     pair is included only once, i.e. if t and s are neighboring pixels
%     then pairs contain either the column [t;s] or [s;t], never both
%   cost_pair [1xM (double)] pairwise costs of edges connecting neighboring
%     pairs of pixels; it holds cost_pair(i) = r(t,s) where pairs(:,i) are
%     either [t;s] or [s;t]
%
% Output:
%   lab [1xN (double)] optimum classification of pixels with respect
%     to the specified unary and pairwise costs; lab(i) is equal to
%     label of the i-th pixel (either 1 or 2)

% current working dir, graphcut file dir, BK library dir
working_dir = pwd();
file_dir = fileparts(mfilename('fullpath'));
bk_dir = strcat(file_dir, '/Bk_matlab');

% initialize
cd(bk_dir);
BK_LoadLib();

% build graph
num_vars = size(cost_unary, 2);
num_pairs = size(cost_pair, 2);
graph = BK_Create(num_vars, num_pairs);
BK_SetUnary(graph, cost_unary);
pot_zero = zeros(num_pairs, 1);
edges = [pairs' pot_zero cost_pair' cost_pair' pot_zero];
BK_SetPairwise(graph, edges);

% find optimum labeling
BK_Minimize(graph);
lab = BK_GetLabeling(graph)';
lab = double(lab);

% clean up
BK_Delete(graph);
cd(working_dir);

end
