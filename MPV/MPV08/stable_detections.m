function [idx] = stable_detections(scores, bboxes, overlap_thr)
%STABLE_DETECTIONS - finds stable non-overlapping detections
%
%   [idx] = stable_detections(scores, bboxes, overlap_thr)
%
%		scores - (1xN) classification score of bounding boxes
%	    bboxes - (4xN) bounding boxes [tlx, tly, brx, bry]
%  overlap_thr - (1x1) threshold on Intersection over Union (IoU) bbox overlap (0.5)
%
%       idx - (1xK) logical output mask denoting the stable detection subset
%
% Algorithm:
%	1. Sort bbox scores in the descending order (creating a queue)
%   2. While the queue is not empty do
%   3.   Take the top-scoring bbox from the queue, add to the solution subset
%   4.   Find overlapping competitors (with lower score) based on IoU overlap
%   5.   Remove the overlaping competitors from the queue. 
%   6. end
%
% IoU ratio can be computed using function bbox_overlap.m
%
[sorted_scores, ind] = sort(scores, 'descend');
nbboxes = bboxes(:, ind);
idx = [];
while ~isempty(nbboxes)
    box = nbboxes(:,1);
    idx = [idx, ind(1)];
    nbboxes(:, 1) = [];
    ind(1) = [];
    to_remove = [];
    for j = 2:size(nbboxes, 2)
        IoU = bbox_overlap(box, nbboxes(:, j));
        if IoU > overlap_thr
            to_remove = [to_remove, j];
        end
    end
    nbboxes(:, to_remove) = [];
    ind(to_remove) = [];
end