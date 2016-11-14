close all;
clear;

% hypothetical 2x2 image with 4-neighborhood: 1 | 3
%                                             2 | 4
pairs = [1 1 2 3; 2 3 4 4];

% unary costs: q1(1) = q1(2) = q1(3) = 1, q1(4) = 4
%              q2(1) = q2(2) = q2(3) = 2, q2(4) = 1
cost_unary = [1 1 1 4; 2 2 2 1];

% pairwise costs: r(1,2) = r(1,3) = r(2,4) = r(3,4) = 1
cost_pair = [1 1 1 1];

% test graphcut
gc_lab = graphcut(cost_unary, pairs, cost_pair);

fprintf('The optimum labeling is:\n\t%i | %i\n\t%i | %i\n', ...
	gc_lab(1), gc_lab(3), gc_lab(2), gc_lab(4));
